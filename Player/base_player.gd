extends BaseEntity2D

# Defines the base functions and variables that all players will have access to
class_name BasePlayer2D

const DEFAULT_RECOVERY_SECONDS: float = 1

var push_force: float = 200.0
var gateway_collectables: float
var boom_collectables: float
var cri_jun_collectables: float
var default_collectables: float

var effective_size := Vector2(32, 32)
	
func retrieve_data(retrieved_from: BaseEntity2D):
	super.retrieve_data(retrieved_from)
	var player_retrieved_from: BasePlayer2D = (retrieved_from as BasePlayer2D)
	if player_retrieved_from != null:
		gateway_collectables = player_retrieved_from.gateway_collectables
		boom_collectables = player_retrieved_from.boom_collectables
		cri_jun_collectables = player_retrieved_from.cri_jun_collectables
		default_collectables = player_retrieved_from.default_collectables

# Rotate the weapon held in hands towards the mouse
func _weapon_rotation_process(weapon_to_rotate: BaseWeapon2D):
	if weapon_to_rotate != null:
		var mouse_pos = get_tree().current_scene.get_viewport().get_mouse_position()
		var screen_pos = get_global_transform_with_canvas().origin
		var look_pos = (mouse_pos - screen_pos) + global_position
		
		weapon_to_rotate.look_at(look_pos)

func _on_get_collectable(collectable: BaseCollectable2D):
	if collectable is DefaultCollectable2D:
		default_collectables += collectable.get_value()
	elif collectable is BoomCollectable2D:
		boom_collectables += collectable.get_value()
	elif collectable is GatewayCollectable2D:
		gateway_collectables += collectable.get_value()
	elif collectable is CriJunCollectable2D:
		cri_jun_collectables += collectable.get_value()

func _ready():
	super._ready()

func _physics_process(delta):
	var direction: Vector2
	
	if cur_knock_duration > 0.0:
		_knockback_procses(delta)
	else:
		if Input.is_action_pressed("right"):
			direction.x += 1
		if Input.is_action_pressed("left"):
			direction.x -= 1
		if Input.is_action_pressed("down"):
			direction.y += 1
		if Input.is_action_pressed("up"):
			direction.y -= 1
		velocity = direction.normalized() * moving_speed
	
	move_and_slide()
	
	## Push pushable objects on contact
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("pushable"):
			collision.get_collider().apply_central_impulse(direction * push_force)
