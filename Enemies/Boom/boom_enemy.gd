extends BaseEnemy2D

class_name BoomEnemy2D

const STAND_TIME: float = 0.1
const FIREBALL_CD_TIME_MAX = 3
const FIREBALL_CD_TIME_MIN = 1

var fireball_scene = preload("res://Enemies/Boom/enemy_fileball.tscn")
@onready var fireball_cd_timer: Timer = $FireballCD
@onready var close_range_area: Area2D = $CloseRange


func _physics_process(delta):
	super._physics_process(delta)
	if spawn_delay != null and spawn_delay.time_left <= 0:
		match thinking_state:
			ThinkState.Targeting:
				if is_player_seen() and fireball_cd_timer.time_left <= 0:
					launch_fireball()

func _ready() -> void:
	super._ready()
	anim = $AnimatedSprite2D


func decide_movement():
	var desired_movement_position: Vector2 = Vector2.INF
	
	pathing_limit_timer.stop()
	
	match thinking_state:
		ThinkState.Neutral:
			## If we have not yet found the player
			if thinking_switch_timer.time_left <= 0:
				desired_movement_position = make_wander_path()
		ThinkState.Targeting:
			
			var total_weight: int = 0
			var roll: int = 0
			var player_seen: bool = is_player_seen()
			
			var straight_weight: int = 1 if player_seen else 4
			var around_weight: int = 5 if player_seen else 2
			var stand_weight: int = 2 if player_seen else 1
			
			total_weight = straight_weight + around_weight + stand_weight
			if total_weight != 0:
				roll = randi() % total_weight
	
			if roll < straight_weight:
				decision_timer.start(DECISION_TIME_DEFAULT)
			elif roll < straight_weight + around_weight:
				desired_movement_position = make_player_around_path()
			else:
				desired_movement_position = make_player_path()
	
	set_pathing_time(desired_movement_position)
	
	return desired_movement_position

#func make_sideways_path():
	#if player_body != null:
		#var sideway = position.direction_to(player_body.position) + Vector2.LEFT*100
		#


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
	#launch_fireball()
	pass
