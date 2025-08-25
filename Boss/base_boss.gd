extends BaseEnemy2D

class_name BaseBoss2D

const BASE_BOSS_MAX_HEALTH: int = 500
const BASE_RECOVERY_TIME: float = 0.5
const BASE_BOSS_DAMAGE: int = 35

const BASE_LAUNCH_CD_MAX: int = 6
const BASE_LAUNCH_CD_MIN: int = 4

const CLOSE_DISTANCE: int = 300

var bound_area: Area2D
@export var blast: PackedScene
@onready var health_bar = $BossHealth

var is_blasting_timer: Timer
var blast_cd_timer: Timer
var is_player_in_arena: bool

func get_blast_cd() -> float:
	return 10 # randi_range(BASE_LAUNCH_CD_MIN, BASE_LAUNCH_CD_MAX)

func get_blast() -> BaseBlast2D:
	if blast == null or not blast.can_instantiate():
		return null
	return blast.instantiate()
	
func retrieve_data(data_from: BaseEntity2D):
	super.retrieve_data(data_from)
	
	if data_from is BaseBoss2D:
		var data_from_boss: BaseBoss2D = data_from as BaseBoss2D
		bound_area = data_from_boss.bound_area
		connect_bound_area()
	
func launch_blast() -> bool:
	if anim:
		anim.play("attack")
	var blast: BaseBlast2D = get_blast()
	if blast == null or player_body == null:
		return false
	var windup_time: float = blast.get_windup_time()
	var persistance_time: float = blast.get_windup_time()
	is_blasting_timer.start(windup_time + persistance_time)
	is_blasting_timer.timeout.connect(_on_blast_timeout)
	add_child(blast)
	global_position = blast.global_position
	blast.aim(player_body.global_position)
	
	return true
 
func get_contact_damage():
	return BASE_BOSS_DAMAGE

func get_max_health():
	return BASE_BOSS_MAX_HEALTH

func get_recovery_time():
	return BASE_RECOVERY_TIME
	
#func is_player_seen() -> bool:
	#return is_player_in_arena

func decide_movement():
	var desired_movement_position: Vector2 = Vector2.INF
	
	pathing_limit_timer.stop()
	
	if not is_player_in_arena:
		thinking_state = ThinkState.Neutral
	else:
		thinking_state = ThinkState.Targeting
	
	var is_center_close: bool = false
	if bound_area != null:
		is_center_close = global_position.distance_to(bound_area.global_position) < 5
	
	match thinking_state:
		ThinkState.Neutral:
			if bound_area != null:
				if is_center_close:
					decision_timer.start(DECISION_TIME_DEFAULT)
				else:
					make_path(bound_area.global_position)
		
		ThinkState.Targeting:
			var total_weight: int = 0
			var roll: int = 0
			
			var blast_weight: int = 5
			var around_weight: int = 2
			var follow_weight: int = 1
			
			total_weight = blast_weight + around_weight + follow_weight
			if total_weight != 0:
				roll = randi() % total_weight
			
			var is_player_close: bool = global_position.distance_to(player_body.global_position) < CLOSE_DISTANCE
			
			
			if is_player_close and blast_cd_timer.time_left <= 0:
				var is_launched: bool = launch_blast()
			elif roll < blast_weight + around_weight and (not is_player_close or is_center_close):
				desired_movement_position = make_player_around_path()
			elif roll < blast_weight + around_weight + follow_weight and (not is_player_close or is_center_close):
				desired_movement_position = make_player_path()
			elif bound_area != null:
				# Go to the center of arena if not already there
				if not is_center_close:
					make_path(bound_area.global_position)
				else:
					decision_timer.start(blast_cd_timer.time_left)
			# Stand still
			else:
				decision_timer.start(DECISION_TIME_DEFAULT)
			
			
	set_pathing_time(desired_movement_position)
	
	return desired_movement_position


func _physics_process(delta):
	if health <= 0:
		return
		
	if is_instance_valid(player_body) and n_agent != null and spawn_delay != null and spawn_delay.time_left <= 0 and on_contact_hit_delay_timer.time_left <= 0:
		if n_agent.target_position != Vector2.INF and decision_timer.time_left <= 0 and is_blasting_timer.time_left <= 0:
			move_to_ntarget()
		# We have an invalid desitination position, try to find another
		elif n_agent.target_position == Vector2.INF:
			decide_movement()
			
	animate()
	$BossHealth.value = health

func _on_blast_timeout():
	blast_cd_timer.start(get_blast_cd())
	decision_timer.start(0.5)

func _on_player_entering_area(body: Node2D):
	if body is BasePlayer2D:
		is_player_in_arena = true
		thinking_state = ThinkState.Targeting
	
func _on_player_exiting_area(body: Node2D):
	if body is BasePlayer2D:
		is_player_in_arena = false
		thinking_state = ThinkState.Neutral

func _ready():
	super._ready()
	
	blast_cd_timer = Timer.new()
	blast_cd_timer.one_shot = true
	blast_cd_timer.autostart = false
	
	
	is_blasting_timer = Timer.new()
	is_blasting_timer.one_shot = true
	is_blasting_timer.autostart = false
	
	add_child(blast_cd_timer)
	add_child(is_blasting_timer)
	
	awareness_raycast.queue_free()
	awareness_raycast = null

func connect_bound_area():
	if bound_area != null:
		
		bound_area.monitoring = true
		if not bound_area.body_entered.is_connected(_on_player_entering_area):
			bound_area.body_entered.connect(_on_player_entering_area)
		if not bound_area.body_exited.is_connected(_on_player_exiting_area):
			bound_area.body_exited.connect(_on_player_exiting_area)

func _on_contact_hitbox_timeout():
	var bodies: Array[Node2D] = on_contact_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body is BasePlayer2D:
			var player: BasePlayer2D = body as BasePlayer2D
			player._on_getting_hit(get_contact_damage(), false, "FirstBoss")
			var dir = global_position.direction_to(body.global_position)
			player.knockback_applied(dir, KNOCKBACK_FORCE, 0.1)
			#global_position += dir * (global_position.distance_to(body.global_position)/2)
			
			decision_timer.start(DECISION_TIME_DEFAULT)
