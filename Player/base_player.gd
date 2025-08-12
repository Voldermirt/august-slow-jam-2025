extends CharacterBody2D

# Defines the base functions and variables that all players will have access to
class_name BasePlayer2D

@export var moving_speed: float = 250.0
var push_force: float = 200.0

var cur_knock_force: Vector2
var cur_knock_duration: float

var effective_size := Vector2(32, 32)

func knockback_applied(direction: Vector2, force: float, duration: float):
	cur_knock_force = direction * force
	cur_knock_duration = duration 
	pass

# Rotate the weapon held in hands towards the mouse
func _weapon_rotation_process(weapon_to_rotate: BaseWeapon2D):
	if weapon_to_rotate != null:
		var mouse_pos = get_tree().current_scene.get_viewport().get_mouse_position()
		var screen_pos = get_global_transform_with_canvas().origin
		var look_pos = (mouse_pos - screen_pos) + global_position
		
		weapon_to_rotate.look_at(look_pos)

## Player is moving the character 
#func _player_movement_process(direction):
	## Normalize to avoid faster diagonal movement

func _on_get_collectable(collectable: BaseCollectable2D):
	pass

func _ready():
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " player is not the child of in the SwitchWrapper"))
		

func _physics_process(delta):
	var direction: Vector2 = Vector2.ZERO

	if cur_knock_duration > 0.0:
		direction = cur_knock_force.normalized()
		velocity = cur_knock_force
		cur_knock_duration -= delta
		if cur_knock_duration <= 0.0:
			cur_knock_force = Vector2.ZERO
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

func _on_hit():
	pass
