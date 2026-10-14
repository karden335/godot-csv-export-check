@tool
extends RefCounted

const SKIP_DIRECTORIES := {
	".git": true,
	".godot": true,
	".venv": true,
	"node_modules": true,
}
const OWN_ADDON_PATH := "res://addons/csv_export_check"


static func scan_project(project_root: String = "res://") -> Dictionary:
	var normalized_root := project_root.trim_suffix("/")
	if normalized_root.is_empty():
		normalized_root = "res://"
	if not DirAccess.dir_exists_absolute(normalized_root):
		return {"ok": false, "error": "%s: project directory does not exist" % normalized_root}
	if not FileAccess.file_exists(normalized_root.path_join("project.godot")):
		return {"ok": false, "error": "%s: project.godot is missing" % normalized_root}

	var references := _collect_references(normalized_root)
	var findings: Array[Dictionary] = []
	var paths: Array = references.keys()
	paths.sort()
	for res_path_value in paths:
		var res_path := str(res_path_value)
		var locations: Array = references[res_path]
		var relative := _safe_relative_path(res_path)
		if relative.is_empty():
			findings.append(_finding(
				"ERROR",
				"UNSAFE_PATH",
				res_path,
				"Path escapes the project or is malformed.",
				"Use a project-relative res:// path without parent traversal.",
			))
			continue

		var source_path := normalized_root.path_join(relative)
		if not FileAccess.file_exists(source_path):
			findings.append(_finding(
				"ERROR",
				"MISSING_SOURCE",
				res_path,
				"Referenced at %s but the source file is absent." % ", ".join(locations),
				"Correct the path or add the file before export.",
			))
			continue

		var importer := _read_importer(source_path + ".import")
		if importer != "keep":
			findings.append(_finding(
				"ERROR",
				"CSV_NOT_KEPT",
				res_path,
				"Importer is %s; FileAccess needs the original CSV in the export." % (importer if not importer.is_empty() else "<unset>"),
				"In the Import dock choose Keep File (No Import), click Reimport, then make a fresh export.",
			))

		var bytes := FileAccess.get_file_as_bytes(source_path)
		if not is_valid_utf8(bytes):
			findings.append(_finding(
				"ERROR",
				"CSV_NOT_UTF8",
				res_path,
				"CSV is not valid UTF-8.",
				"Save the file as UTF-8, reimport it, and test again.",
			))
		elif bytes.size() >= 3 and bytes[0] == 0xEF and bytes[1] == 0xBB and bytes[2] == 0xBF:
			findings.append(_finding(
				"WARNING",
				"CSV_BOM",
				res_path,
				"A UTF-8 byte-order mark appears before the first field.",
				"Save without BOM if your parser expects the first header to begin at byte 0.",
			))

	if references.is_empty():
		findings.append(_finding(
			"WARNING",
			"NO_LITERAL_CSV_PATHS",
			"",
			"No literal raw CSV FileAccess paths were found; variable-built paths are outside this scan.",
			"Run the exported game and exercise paths assembled at runtime.",
		))

	var errors := 0
	var warnings := 0
	for finding in findings:
		if finding.severity == "ERROR":
			errors += 1
		elif finding.severity == "WARNING":
			warnings += 1
	return {
		"ok": true,
		"project": normalized_root,
		"csv_paths_checked": references.size(),
		"findings": findings,
		"summary": {"errors": errors, "warnings": warnings},
		"limits": "Source-only scan. Export and run the actual target build before release.",
	}


static func is_valid_utf8(bytes: PackedByteArray) -> bool:
	var index := 0
	while index < bytes.size():
		var first := int(bytes[index])
		if first <= 0x7F:
			index += 1
			continue
		if first >= 0xC2 and first <= 0xDF:
			if not _has_continuations(bytes, index, 1):
				return false
			index += 2
			continue
		if first >= 0xE0 and first <= 0xEF:
			if index + 2 >= bytes.size():
				return false
			var second := int(bytes[index + 1])
			var third := int(bytes[index + 2])
			if third < 0x80 or third > 0xBF:
				return false
			if first == 0xE0 and (second < 0xA0 or second > 0xBF):
				return false
			if first == 0xED and (second < 0x80 or second > 0x9F):
				return false
			if first != 0xE0 and first != 0xED and (second < 0x80 or second > 0xBF):
				return false
			index += 3
			continue
		if first >= 0xF0 and first <= 0xF4:
			if index + 3 >= bytes.size():
				return false
			var second := int(bytes[index + 1])
			if first == 0xF0 and (second < 0x90 or second > 0xBF):
				return false
			if first == 0xF4 and (second < 0x80 or second > 0x8F):
				return false
			if first != 0xF0 and first != 0xF4 and (second < 0x80 or second > 0xBF):
				return false
			if not _has_continuations(bytes, index + 1, 2):
				return false
			index += 4
			continue
		return false
	return true


static func _collect_references(project_root: String) -> Dictionary:
	var references: Dictionary = {}
	var scripts: Array[String] = []
	_collect_scripts(project_root, scripts)
	var expression := RegEx.new()
	var compile_error := expression.compile("FileAccess\\s*\\.\\s*(?:open|file_exists|get_file_as_string)\\s*\\(\\s*['\"](res://[^'\"]+\\.csv)['\"]")
	if compile_error != OK:
		return references
	for script in scripts:
		var source := FileAccess.get_file_as_string(script)
		var lines := source.split("\n")
		for match in expression.search_all(source):
			var line_number := source.substr(0, match.get_start()).count("\n") + 1
			if line_number <= lines.size() and str(lines[line_number - 1]).strip_edges().begins_with("#"):
				continue
			var res_path := match.get_string(1)
			if not references.has(res_path):
				references[res_path] = []
			var location := "%s:%d" % [_display_path(script, project_root), line_number]
			references[res_path].append(location)
	return references


static func _collect_scripts(directory: String, scripts: Array[String]) -> void:
	var access := DirAccess.open(directory)
	if access == null:
		return
	access.list_dir_begin()
	var entry := access.get_next()
	while not entry.is_empty():
		if access.current_is_dir():
			var child := directory.path_join(entry)
			if not SKIP_DIRECTORIES.has(entry) and child != OWN_ADDON_PATH:
				_collect_scripts(child, scripts)
		elif entry.ends_with(".gd"):
			scripts.append(directory.path_join(entry))
		entry = access.get_next()
	access.list_dir_end()


static func _read_importer(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return ""
	return str(config.get_value("remap", "importer", ""))


static func _safe_relative_path(res_path: String) -> String:
	if not res_path.begins_with("res://"):
		return ""
	var relative := res_path.trim_prefix("res://")
	if relative.is_empty() or "\\" in relative:
		return ""
	for part in relative.split("/"):
		if part.is_empty() or part == "." or part == "..":
			return ""
	return relative


static func _has_continuations(bytes: PackedByteArray, start: int, count: int) -> bool:
	if start + count >= bytes.size():
		return false
	for offset in range(1, count + 1):
		var value := int(bytes[start + offset])
		if value < 0x80 or value > 0xBF:
			return false
	return true


static func _display_path(path: String, project_root: String) -> String:
	var prefix := project_root.trim_suffix("/") + "/"
	return path.trim_prefix(prefix)


static func _finding(severity: String, code: String, path: String, detail: String, fix: String) -> Dictionary:
	return {
		"severity": severity,
		"code": code,
		"path": path,
		"detail": detail,
		"fix": fix,
	}
