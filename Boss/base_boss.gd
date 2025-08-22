extends BaseEnemy2D

class_name BaseBoss2D

const BASE_BOSS_MAX_HEALTH: int = 500
const BASE_RECOVERY_TIME: float = 0.5
const BASE_BOSS_DAMAGE: int = 35

@export var bound_area: Area2D
var is_player_in_arena: bool

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
	
	match thinking_state:
		ThinkState.Neutral:
			make_path(bound_area.global_position)
		ThinkState.Targeting:
			var total_weight: int = 0
			var roll: int = 0
			
			var straight_weight: int = 1 
			var around_weight: int = 3
			var stand_weight: int = 5
			
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

func _on_player_entering_area(body: Node2D):
	if body is BasePlayer2D:
		is_player_in_arena = true
		thinking_state = ThinkState.Targeting
		decide_movement()
	
func _on_player_exiting_area(body: Node2D):
	if body is BasePlayer2D:
		is_player_in_arena = false
		thinking_state = ThinkState.Neutral
		decide_movement()

func _ready():
	super._ready()
	
	if bound_area != null and not bound_area.body_entered.is_connected(_on_player_entering_area):
		bound_area.body_entered.connect(_on_player_entering_area)
	if bound_area != null and not bound_area.body_exited.is_connected(_on_player_exiting_area):
		bound_area.body_exited.connect(_on_player_exiting_area)
