extends Node2D

signal all_enemies_died

var enemies_killed: int = 0

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
	await get_tree().process_frame
	connect_enemies()
	Globals.game_changed.connect(connect_enemies)
	if get_num_enemies() == 0:
		all_enemies_died.emit()

func connect_enemies(_game=null):
	await get_tree().process_frame
	for enemy in get_enemies():
		if enemy is BaseEnemy2D and not (enemy as BaseEnemy2D).death.is_connected(_on_enemy_death):
			(enemy as BaseEnemy2D).death.connect(_on_enemy_death)

func _on_enemy_death():
	await get_tree().process_frame
	#enemies_killed += 1
	if get_num_enemies() - get_dead_enemies() <= 0:
		all_enemies_died.emit()

func get_dead_enemies():
	var count = 0
	for enemy in get_enemies():
		if enemy.health <= 0:
			count += 1
	return count
