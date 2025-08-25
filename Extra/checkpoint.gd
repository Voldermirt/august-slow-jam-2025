extends Area2D

class_name Checkpoint

signal trigger_checkpoint

func _on_body_entered(body: Node):
	if body is BasePlayer2D:
		trigger_checkpoint.emit()
		# Make sure to delete all portals
		for gateway in get_tree().get_nodes_in_group("delete_on_load"):
			gateway.queue_free()
		Globals.save_game()
		$SaveSound.play()
