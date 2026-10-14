extends SceneTree

const CsvExportAnalyzer = preload("res://addons/csv_export_check/csv_export_analyzer.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var good := CsvExportAnalyzer.scan_project("res://tests/fixture")
	if not good.ok:
		_fail("corrected fixture did not scan: %s" % good.error)
		return
	if good.csv_paths_checked != 1 or not good.findings.is_empty():
		_fail("corrected fixture should pass: %s" % good)
		return

	var broken := CsvExportAnalyzer.scan_project("res://tests/broken")
	if not broken.ok:
		_fail("broken fixture did not scan: %s" % broken.error)
		return
	var codes: Array[String] = []
	for finding in broken.findings:
		codes.append(finding.code)
	if "CSV_NOT_KEPT" not in codes:
		_fail("broken fixture did not report CSV_NOT_KEPT: %s" % broken)
		return

	if not CsvExportAnalyzer.is_valid_utf8(PackedByteArray([0x61, 0xC3, 0xA9])):
		_fail("valid UTF-8 was rejected")
		return
	if CsvExportAnalyzer.is_valid_utf8(PackedByteArray([0xC0, 0xAF])):
		_fail("overlong UTF-8 was accepted")
		return
	if CsvExportAnalyzer.is_valid_utf8(PackedByteArray([0xED, 0xA0, 0x80])):
		_fail("UTF-8 surrogate was accepted")
		return

	print("PASS: CsvExportAnalyzer")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
