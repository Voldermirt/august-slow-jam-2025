extends BaseWeapon2D
class_name DoomGun

const Bullet := preload("res://Player/Boom/boom_bullet.tscn")

@export var max_ammo := 10
@export var shoot_cooldown := 0.1
@export var reload_cooldown := 1.0

@onready var cooldown_timer := $Cooldown
@onready var ammo := max_ammo


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		shoot()
	if Input.is_action_just_pressed("secondary"):
		reload()

func shoot():
	if ammo <= 0 or not cooldown_timer.is_stopped():
		return
	var bullet = Bullet.instantiate()
	Globals.get_2d_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = Vector2.RIGHT.rotated(global_rotation)
	ammo -= 1
	cooldown_timer.start(shoot_cooldown)

func reload():
	if not cooldown_timer.is_stopped():
		return
	cooldown_timer.start(reload_cooldown)
	ammo = max_ammo

func update_ammo_gui():
	pass
	# Implement this function once the GUI exists
