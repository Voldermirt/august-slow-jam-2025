extends BaseProjectile2D

class_name BoomProjectile2D

#func get_speed():
	#return 250

func get_damage():
	return 35

func _physics_process(delta: float) -> void:
	_player_projectile_Process(delta)
