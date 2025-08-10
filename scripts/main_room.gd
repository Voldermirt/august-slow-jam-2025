extends Node3D
class_name MainRoom

@onready var zoom_anim := $ZoomAnim
@onready var camera_3d := $Camera3D

var zoom_out = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom") and not zoom_out:
		#$ZoomAnim.pause()
		zoom_out = true
		$ZoomAnim.play("zoom")
	elif event.is_action_released("zoom") and zoom_out:
		#$ZoomAnim.pause()
		zoom_out = false
		$ZoomAnim.play_backwards("zoom")
