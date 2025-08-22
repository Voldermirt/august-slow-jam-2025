extends CharacterBody2D

class_name BaseProjectile2D

const BASE_DAMAGE: float = 10

@export var base_speed := 600

var direction := Vector2.RIGHT

func get_speed():
	return base_speed

func get_damage():
	return BASE_DAMAGE
	
func _ready() -> void:
	Globals.game_changed.connect(game_changed)
	#if (collision_mask & BasePlayer2D.ENEMY_LAYER_NUMER) == 0:
		#collision_mask += BasePlayer2D.ENEMY_LAYER_NUMER

func _player_projectile_Process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col: KinematicCollision2D = move_and_collide(direction * get_speed() * delta)
	
	if col and col.get_collider() != null:
		var collider: Object = col.get_collider()
		if collider is BaseEnemy2D:
			var enemy: BaseEnemy2D = collider as BaseEnemy2D
			enemy._on_getting_hit(get_damage())
			
		if collider is BaseObject2D:
			var object: BaseObject2D = collider as BaseObject2D
			object.receive_damage(self)
		hide()
		queue_free()

func _enemy_projectile_process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col: KinematicCollision2D = move_and_collide(direction * get_speed() * delta)
	
	if col and col.get_collider() != null:
		var collider: Object = col.get_collider()
		if collider is BasePlayer2D:
			(collider as BasePlayer2D)._on_getting_hit(get_damage())
			
		hide()
		queue_free()

func game_changed(_game):
	queue_free()
