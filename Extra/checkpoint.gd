extends Area2D

class_name Checkpoint

func _on_body_entered(body: Node):
	if body is BasePlayer2D:
		Globals.save_game()
