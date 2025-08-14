extends Camera2D


func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		global_position = player.global_position
