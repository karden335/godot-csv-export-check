@tool
extends VBoxContainer

const CsvExportAnalyzer = preload("res://addons/csv_export_check/csv_export_analyzer.gd")

var project_root := "res://"
var run_button: Button
var result_value: TextEdit


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var title := Label.new()
	title.text = "CSV Export Check"
	title.add_theme_font_size_override("font_size", 18)
	add_child(title)

	var explanation := Label.new()
	explanation.text = "Find literal raw CSV paths that can work in the editor but disappear or change in an exported build. Files stay on this computer."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(explanation)

	run_button = Button.new()
	run_button.text = "Scan current project"
	run_button.pressed.connect(_run_check)
	add_child(run_button)

	var hint := Label.new()
	hint.text = "Fix errors, make a fresh export, then launch and test the exported game."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(hint)

	result_value = TextEdit.new()
	result_value.editable = false
	result_value.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	result_value.placeholder_text = "Results will appear here."
	result_value.custom_minimum_size = Vector2(0, 280)
	result_value.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(result_value)


func _run_check() -> void:
	run_button.disabled = true
	result_value.text = "Scanning…"
	var report := CsvExportAnalyzer.scan_project(project_root)
	if not report.ok:
		result_value.text = "ERROR\n%s" % report.error
		run_button.disabled = false
		return

	var lines: PackedStringArray = []
	lines.append("Checked %d literal CSV path(s)." % report.csv_paths_checked)
	for finding in report.findings:
		var path_label: String = finding.path if not finding.path.is_empty() else "project"
		lines.append("")
		lines.append("%s %s %s" % [finding.severity, finding.code, path_label])
		lines.append("  %s" % finding.detail)
		lines.append("  Fix: %s" % finding.fix)
	if report.findings.is_empty():
		lines.append("PASS: no source-side risks found in the covered checks.")
	lines.append("")
	lines.append("SUMMARY: %d error(s), %d warning(s)" % [
		report.summary.errors,
		report.summary.warnings,
	])
	lines.append(report.limits)
	result_value.text = "\n".join(lines)
	run_button.disabled = false
