extends BasePlayer2D

class_name BoomPlayer2D

const BOOM_PLAYER_MAX_HEALTH: float = 100
const DASH_DURATION_TIME: float = 0.1
const DASH_CD_TIME: float = 1
const DASH_STRENGTH: float = 300
const MAX_DASHES: int = 2

@onready var dash_cd_timer: Timer = $DashCD
@onready var dash_duration_timer: Timer = $DashDuration
@onready var weapon := $BoomGun

var available_dashes: int = MAX_DASHES

func get_max_health():
	return BOOM_PLAYER_MAX_HEALTH

func perform_dash():
	if available_dashes > 0:
		dash_duration_timer.start(DASH_DURATION_TIME)
		if dash_cd_timer.time_left <= 0:
			dash_cd_timer.start(DASH_CD_TIME)
		
		allowed_to_move = false
		is_invincible = true
		available_dashes -= 1
		
		velocity = movement_direction.normalized() * DASH_STRENGTH
		return true
	return false
	
func _ready():
	super._ready()
	anim = $AnimatedSprite2D
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		weapon.shoot()
	if Input.is_action_just_pressed("secondary"):
		if dash_duration_timer.time_left <= 0 and allowed_to_move and available_dashes > 0:
			perform_dash()

	#PlayerStats.cooldown = cooldown_timer.time_left

func _physics_process(delta):
	super._physics_process(delta)
	if Input.is_action_pressed("secondary") and dash_duration_timer.time_left <= 0 and allowed_to_move:
		perform_dash()
		anim.play("dash")
	
	if dash_duration_timer.time_left > 0:
		move_and_slide()
		
	_weapon_rotation_process(weapon)

func retrieve_data(retrieved_from: BaseEntity2D):
	super.retrieve_data(retrieved_from)

func _on_dash_duration_timeout():
	anim.play("walk")
	allowed_to_move = true
	is_invincible = false

func _on_dash_cd_timeout():
	if available_dashes < MAX_DASHES:
		available_dashes += 1
	
	if available_dashes < MAX_DASHES:
		dash_cd_timer.start(DASH_CD_TIME)
