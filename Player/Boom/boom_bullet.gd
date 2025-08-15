extends CharacterBody2D

@export var speed := 600

var damage: float = 10

var direction := Vector2.RIGHT

func _ready() -> void:
	Globals.game_changed.connect(game_changed)
	#if (collision_mask & BasePlayer2D.ENEMY_LAYER_NUMER) == 0:
		#collision_mask += BasePlayer2D.ENEMY_LAYER_NUMER

func game_changed(_game):
	queue_free()

func _physics_process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col: KinematicCollision2D = move_and_collide(direction * speed * delta)
	
	if col and col.get_collider() != null:
		var collider: Object = col.get_collider()
		if collider is BaseEnemy2D:
			var enemy: BaseEnemy2D = collider as BaseEnemy2D
			enemy._on_getting_hit(damage)
			
		if collider is BaseObject2D:
			var object: BaseObject2D = collider as BaseObject2D
			object.receive_damage(self)
		hide()
		queue_free()
		
		
