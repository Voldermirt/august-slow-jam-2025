extends Control


var main_scene := preload("res://Map/main_room.tscn")

func _ready() -> void:
	Globals.can_switch = false

func _on_play() -> void:
	Globals.can_switch = true
	#Globals.change_level(main_scene)
	get_tree().change_scene_to_packed(main_scene)

func _on_quit() -> void:
	get_tree().quit()
