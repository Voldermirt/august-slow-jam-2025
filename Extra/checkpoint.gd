extends Area2D

class_name Checkpoint

signal trigger_checkpoint

func _on_body_entered(body: Node):
	if body is BasePlayer2D:
		trigger_checkpoint.emit()
		Globals.save_game()
		$SaveSound.play()
