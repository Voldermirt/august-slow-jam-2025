extends BaseProjectile2D

class_name BoomProjectile2D

func _physics_process(delta: float) -> void:
	_player_projectile_Process(delta)
