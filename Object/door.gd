extends StaticBody2D


func _ready() -> void:
	if get_parent().is_in_group("room"):
		get_parent().all_enemies_died.connect(_on_all_enemies_dead)
	else:
		_on_all_enemies_dead()

func _on_all_enemies_dead():
	# Play a sound
	queue_free()
