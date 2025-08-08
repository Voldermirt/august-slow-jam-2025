extends CharacterBody2D

class_name PlayerCharacter2D

@onready var weapon: PlayerWeapon = $Weapon

var moving_speed: float = 500

func _weapon_rotation_process():
	weapon.look_at(get_global_mouse_position())

func _player_movement_process():
	var direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("player_move_right"):
		direction.x += 1
	if Input.is_action_pressed("player_move_left"):
		direction.x -= 1
	if Input.is_action_pressed("player_move_down"):
		direction.y += 1
	if Input.is_action_pressed("player_move_up"):
		direction.y -= 1

	# Normalize to avoid faster diagonal movement
	self.velocity = direction.normalized() * moving_speed
	
	move_and_slide()


func _physics_process(delta):
	_player_movement_process()
	_weapon_rotation_process()
