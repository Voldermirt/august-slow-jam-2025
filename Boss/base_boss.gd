extends BaseEnemy2D

class_name BaseBoss2D

const BASE_BOSS_MAX_HEALTH: int = 500
const BASE_RECOVERY_TIME: float = 0.5

func get_max_health():
	return BASE_BOSS_MAX_HEALTH

func get_recovery_time():
	return BASE_RECOVERY_TIME

func decide_movement():
	var desired_movement_position: Vector2 = Vector2.INF
	
	pathing_limit_timer.stop()

	var total_weight: int = 0
	var roll: int = 0
	var player_seen: bool = is_player_seen()
	
	var straight_weight: int = 1 
	var around_weight: int = 5 
	var stand_weight: int = 2
	
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
