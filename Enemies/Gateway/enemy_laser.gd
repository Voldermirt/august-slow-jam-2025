extends BaseProjectile2D

class_name EnemyLaser2D

func get_damage():
	return 50

func get_speed():
	return 1000

func _physics_process(delta: float) -> void:
	_enemy_projectile_process(delta)
