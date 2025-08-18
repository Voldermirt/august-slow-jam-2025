extends BaseProjectile2D

class_name FireballProjectile2D

func _physics_process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col: KinematicCollision2D = move_and_collide(direction * speed * delta)
	
	if col and col.get_collider() != null:
		var collider: Object = col.get_collider()
		if collider is BasePlayer2D:
			(collider as BasePlayer2D)._on_getting_hit(damage)
			
		hide()
		queue_free()
