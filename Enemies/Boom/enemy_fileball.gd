extends BaseProjectile2D

class_name FireballProjectile2D

func _physics_process(delta: float) -> void:
	_enemy_projectile_process(delta)
