extends Area2D

signal on
signal off

# can be used for like animations or noises or something
var is_on = false

func _on_body_entered(body: Node2D) -> void:
	if body is GatewayObject2D or GatewayPlayer2D:
		emit_signal("on")
		is_on = true


func _on_body_exited(body: Node2D) -> void:
	if body is GatewayObject2D or GatewayPlayer2D:
		emit_signal("off")
		is_on = false
