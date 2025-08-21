extends Area2D

class_name Checkpoint

func _process(delta):
	if OS.is_debug_build() and Input.is_action_pressed("interact"):
		Globals.load_game()

func _on_body_entered(body: Node):
	if body is BasePlayer2D:
		Globals.save_game()
