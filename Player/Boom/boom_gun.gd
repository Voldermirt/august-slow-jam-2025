extends BaseWeapon2D
class_name DoomGun

const Bullet := preload("res://Player/Boom/boom_bullet.tscn")

@export var max_ammo := 10
@export var shoot_cooldown := 0.1
@export var reload_cooldown := 1.0

@onready var autoreload_timer: Timer = $AudoReload
@onready var cooldown_timer := $Cooldown
@onready var ammo := max_ammo

func _ready() -> void:
	PlayerStats.ammo = ammo

func shoot():
	if ammo <= 0 or not cooldown_timer.is_stopped():
		return
	var bullet = Bullet.instantiate()
	Globals.get_2d_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = Vector2.RIGHT.rotated(global_rotation)
	
	ammo -= 1
	cooldown_timer.start(shoot_cooldown)
	
	PlayerStats.ammo = ammo
	PlayerStats.max_cooldown = shoot_cooldown
	PlayerStats.cooldown = shoot_cooldown
	autoreload_timer.start()

func reload():
	if not cooldown_timer.is_stopped():
		return
	autoreload_timer.stop()
	
	cooldown_timer.start(reload_cooldown)
	PlayerStats.max_cooldown = reload_cooldown
	PlayerStats.cooldown = reload_cooldown
	await cooldown_timer.timeout
	ammo = max_ammo
	PlayerStats.ammo = ammo


func _on_audo_reload_timeout():
	reload()
