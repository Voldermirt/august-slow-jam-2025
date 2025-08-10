extends Area2D

class_name BaseCollectable2D

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("player"):
		pass
