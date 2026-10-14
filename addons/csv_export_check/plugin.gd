@tool
extends EditorPlugin

const CsvExportDock = preload("res://addons/csv_export_check/csv_export_dock.gd")

var dock: Control


func _enter_tree() -> void:
	dock = CsvExportDock.new()
	dock.name = "CSV Export Check"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree() -> void:
	if is_instance_valid(dock):
		remove_control_from_docks(dock)
		dock.queue_free()
	dock = null
