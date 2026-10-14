extends SceneTree

const CsvExportDock = preload("res://addons/csv_export_check/csv_export_dock.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var dock := CsvExportDock.new()
	dock.project_root = "res://tests/broken"
	root.add_child(dock)
	await process_frame
	dock._run_check()
	var text: String = dock.result_value.text
	if "ERROR CSV_NOT_KEPT" not in text:
		_fail("dock did not show the import problem: %s" % text)
		return
	if "SUMMARY: 1 error(s), 0 warning(s)" not in text:
		_fail("dock did not show the expected summary: %s" % text)
		return
	if dock.run_button.disabled:
		_fail("scan button remained disabled")
		return
	print("PASS: CsvExportDock end-to-end flow")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
