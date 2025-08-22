extends BaseEnemy2D

class_name GatewayEnemy2D

@onready var laser_cd_timer: Timer = $LaserCd

var laser_scene := preload("res://Enemies/Gateway/enemy_laser.tscn")

func _ready():
	super._ready()
	pass

func _physics_process(delta):
	super._physics_process(delta)
	if health <= 0:
		return 
		
	if spawn_delay != null and spawn_delay.time_left <= 0:
		match thinking_state:
			ThinkState.Targeting:
				if is_player_seen() and laser_cd_timer.time_left <= 0:
					launch_laser()

func launch_laser():
	if not player_body:
		return
	var projectile: EnemyLaser2D = laser_scene.instantiate()
	var destination = player_body.global_position
	
	Globals.get_2d_root().add_child(projectile)
	projectile.direction = global_position.direction_to(destination)
	projectile.global_position = global_position
	laser_cd_timer.start(randi_range(0.5, 1))


func decide_movement():
	pass
