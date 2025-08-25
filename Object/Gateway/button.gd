extends Area2D

class_name GatewayButton2D

signal on
signal off

# can be used for like animations or noises or something
var is_on = false

func save_json_data() -> Dictionary:
	var base_data = {
		"global_position": global_position
	}
	return base_data

func load_json_data(data: Dictionary):
	global_position = str_to_var("Vector2" + data["global_position"])

var player : BasePlayer2D

func _on_body_entered(body: Node2D) -> void:
	if is_pressed() and not is_on and is_inside_tree():
		emit_signal("on")
		is_on = true
		$PressSound.play()


func _on_body_exited(body: Node2D) -> void:
	if not is_pressed() and is_on and is_inside_tree():
		emit_signal("off")
		is_on = false
		$ReleaseSound.play()

func is_pressed():
	for body in get_overlapping_bodies():
		if body is GatewayObject2D or body is GatewayPlayer2D:
			return true
	return false
