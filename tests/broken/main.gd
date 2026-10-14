extends Node


func _ready() -> void:
	print(FileAccess.get_file_as_string("res://data/monsters.csv"))
