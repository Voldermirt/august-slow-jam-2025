extends Node
class_name MainRoom

@onready var zoom_anim := %ZoomAnim
@onready var view_3d := $Render3D

@onready var level = $Render2D/Level2D/Level

var zoom_out = false

func _ready() -> void:
	Globals.level_change_requested.connect(change_level)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom") and not zoom_out:
		# Zoom out
		view_3d.visible = true
		zoom_out = true
		zoom_anim.play("zoom")
	elif event.is_action_released("zoom") and zoom_out:
		# Zoom in
		zoom_out = false
		zoom_anim.play_backwards("zoom")



func _on_zoom_anim_animation_finished(anim_name: StringName) -> void:
	if not zoom_out:
		view_3d.visible = false

func change_level(new_level : PackedScene):
	level.queue_free()
	level = new_level.instantiate()
	$Render2D/Level2D.add_child(level)
