extends CharacterBody2D

# Defines the base functions and variables that all players will have access to
class_name BasePlayer2D

var moving_speed: float = 500

# Rotate the weapon held in hands towards the mouse
func _weapon_rotation_process(weapon_to_rotate: BaseWeapon2D):
	if weapon_to_rotate != null:
		var screen_size = get_viewport_rect().size
		var mouse_pos = get_tree().current_scene.get_viewport().get_mouse_position()
		#print(mouse_pos - screen_size / 2)
		weapon_to_rotate.look_at((mouse_pos - screen_size / 2) + global_position)


# Player is moving the character 
func _player_movement_process():
	#var direction := Input.get_vector("left", "right", "up", "down")
	var direction := Vector2()

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


func _ready():
	if not get_parent().is_in_group("switch_wrapper"):
		push_error(str(self, " player/object is not the child of in the SwitchWrapper"))
