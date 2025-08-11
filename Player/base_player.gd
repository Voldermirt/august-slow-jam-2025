extends CharacterBody2D

# Defines the base functions and variables that all players will have access to
class_name BasePlayer2D

var moving_speed: float = 500.0
var push_force: float = 200.0

# Rotate the weapon held in hands towards the mouse
func _weapon_rotation_process(weapon_to_rotate: BaseWeapon2D):
	if weapon_to_rotate != null:
		weapon_to_rotate.look_at(get_global_mouse_position())


# Player is moving the character 
func _player_movement_process():
	var direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	# Normalize to avoid faster diagonal movement
	self.velocity = direction.normalized() * moving_speed
	
	move_and_slide()
	
	## Push pushable objects on contact
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("pushable"):
			collision.get_collider().apply_central_impulse(direction * push_force)


func _ready():
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " player is not the child of in the SwitchWrapper"))
		

func _physics_process(delta):
	_player_movement_process()
