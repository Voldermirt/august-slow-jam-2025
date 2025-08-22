extends BaseCollectable2D

class_name CriJunCollectable2D

func _on_body_entered(body: CharacterBody2D):
	if body is BasePlayer2D:
		var player = body as BasePlayer2D
		PlayerStats.fruit_count[$Sprite2D.frame] += 1
		player._on_get_collectable(self)
		get_parent().queue_free()
