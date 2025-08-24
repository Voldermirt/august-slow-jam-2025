extends BaseProjectile2D

class_name FireballProjectile2D

const CACODEMON_FIREBALL_SPEED = 300

func _physics_process(delta: float) -> void:
	_enemy_projectile_process(delta)

func get_speed():
	return CACODEMON_FIREBALL_SPEED
