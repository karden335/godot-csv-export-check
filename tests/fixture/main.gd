extends Node

func _ready():
	var file = FileAccess.open("res://data/monsters.csv", FileAccess.READ)
	if file == null:
		printerr("MISSING_CSV")
		get_tree().quit(2)
		return
	print("CSV_OK:" + file.get_line())
	get_tree().quit(0)
