extends BaseEnemy2D

class_name GatewayEnemy2D

@onready var laser_cd_timer: Timer = $LaserCd

# cause they 2 hit you lol, gotta balance it
const TURRET_HEALTH = 1

var laser_scene := preload("res://Enemies/Gateway/enemy_laser.tscn")

var face_down = false

func _ready():
	anim = $AnimatedSprite2D
	super._ready()
	pass

func get_max_health():
	return TURRET_HEALTH

func _physics_process(delta):
	super._physics_process(delta)
	while awareness_raycast.rotation_degrees > 360:
		awareness_raycast.rotation_degrees -= 360
	while awareness_raycast.rotation_degrees < 0:
		awareness_raycast.rotation_degrees += 360
	if face_down:
		awareness_raycast.rotation_degrees = clamp(awareness_raycast.rotation_degrees, 20, 170)
	else:
		awareness_raycast.rotation_degrees = clamp(awareness_raycast.rotation_degrees, 110, 250)
	
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
	$LaserSound.play()


func decide_movement():
	pass
