extends Node2D

signal all_enemies_died

func get_num_enemies():
	return len(get_enemies())
	
func get_enemies():
	var enemies = []
	for child in get_children():
		if child.is_in_group("enemy") or child.is_in_group("boss"):
			if child is SwitchWrapper2D:
				enemies.append(child.get_child(0))
			else:
				enemies.append(child)
	return enemies

func _ready() -> void:
	connect_enemies()
	Globals.game_changed.connect(connect_enemies)
	if get_num_enemies() == 0:
		all_enemies_died.emit()

func connect_enemies(_game=null):
	await get_tree().process_frame
	for enemy in get_enemies():
		enemy.death.connect(_on_enemy_death)

func _on_enemy_death():
	await get_tree().process_frame
	if get_num_enemies() <= 0:
		all_enemies_died.emit()
