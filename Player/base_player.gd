extends BaseEntity2D

# Defines the base functions and variables that all players will have access to
class_name BasePlayer2D

signal player_instantiated

const BASE_PLAYER_MAX_HEALTH: float = 100
const DEFAULT_RECOVERY_SECONDS: float = 1

var push_force: float = 200.0

var collectables: float = 0
var movement_direction: Vector2 = Vector2.ZERO
 
var effective_size := Vector2(32, 32)

var last_checkpoint: Vector2

var anim : AnimatedSprite2D = null

func retrieve_data(retrieved_from: BaseEntity2D):
	super.retrieve_data(retrieved_from)
	var player_retrieved_from: BasePlayer2D = (retrieved_from as BasePlayer2D)
	if player_retrieved_from != null:
		collectables = player_retrieved_from.collectables

func get_max_health():
	return BASE_PLAYER_MAX_HEALTH
	
# Rotate the weapon held in hands towards the mouse
func _weapon_rotation_process(weapon_to_rotate: BaseWeapon2D):
	if weapon_to_rotate != null:
		var mouse_pos = get_tree().current_scene.get_viewport().get_mouse_position()
		var screen_pos = get_global_transform_with_canvas().origin
		var look_pos = (mouse_pos - screen_pos) + global_position
		
		weapon_to_rotate.look_at(look_pos)

func _on_get_collectable(found_collectable: BaseCollectable2D):
	self.collectables += found_collectable.get_value()
	

func _ready():
	super._ready()
	
	#if (collision_layer & PLAYER_LAYER_NUMBER) == 0:
		#collision_layer += PLAYER_LAYER_NUMBER
	#if (collision_mask & ENEMY_LAYER_NUMER) == 0:
		#collision_mask += ENEMY_LAYER_NUMER
	

func _physics_process(delta):
	
	movement_direction = Vector2.ZERO
	
	if cur_knock_duration > 0.0:
		_knockback_proccess(delta)
	else:
		if allowed_to_move:
			if Input.is_action_pressed("right"):
				movement_direction.x += 1
			if Input.is_action_pressed("left"):
				movement_direction.x -= 1
			if Input.is_action_pressed("down"):
				movement_direction.y += 1
			if Input.is_action_pressed("up"):
				movement_direction.y -= 1
			
			velocity = movement_direction.normalized() * moving_speed
	
	move_and_slide()
	
	_push_objects()
	
	# Animate
	if anim:
		if movement_direction.length() > 0:
			anim.play("walk")
		else:
			anim.play("idle")
		
		if movement_direction.x > 0:
			anim.flip_h = false
		elif movement_direction.x < 0:
			anim.flip_h = true

func _push_objects():
	## Push pushable objects on contact
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("pushable"):
			collision.get_collider().apply_central_impulse(movement_direction * push_force)
	
