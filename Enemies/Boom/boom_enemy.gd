extends BaseEnemy2D

class_name BoomEnemy2D

func _ready() -> void:
	super._ready()
	anim = $AnimatedSprite2D

const FIREBALL_CD_TIME_MAX = 3
const FIREBALL_CD_TIME_MIN = 1

var fireball_scene = preload("res://Enemies/Boom/enemy_fileball.tscn")
@onready var fireball_cd_timer: Timer = $FireballCD
@onready var close_range_area: Area2D = $CloseRange


func launch_fireball():
	if not player_body:
		return
	var fireball_projectile: FireballProjectile2D = fireball_scene.instantiate()
	var destination = player_body.global_position
	
	Globals.get_2d_root().add_child(fireball_projectile)
	fireball_projectile.direction = global_position.direction_to(destination)
	fireball_projectile.global_position = global_position
	fireball_cd_timer.start(randi_range(FIREBALL_CD_TIME_MIN, FIREBALL_CD_TIME_MAX))

func _on_fireball_cd_timeout():
	launch_fireball()
