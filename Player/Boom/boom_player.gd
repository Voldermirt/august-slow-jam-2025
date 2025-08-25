extends BasePlayer2D

class_name BoomPlayer2D

const BOOM_PLAYER_MAX_HEALTH: float = 100
const DASH_DURATION_TIME: float = 0.5
const DASH_CD_TIME: float = 1
const DASH_STRENGTH: float = 100
const MAX_DASHES: int = 2

const DASH_PARTICLES = preload("res://Player/Boom/dash_particles.tscn")

@onready var dash_cd_timer: Timer = $DashCD
@onready var dash_duration_timer: Timer = $DashDuration
@onready var weapon := $BoomGun
@onready var step_sound := $FootstepSound

var available_dashes: int = MAX_DASHES

func get_max_health():
	return BOOM_PLAYER_MAX_HEALTH

func perform_dash():
	if available_dashes > 0:
		dash_duration_timer.start(DASH_DURATION_TIME)
		if dash_cd_timer.time_left <= 0:
			dash_cd_timer.start(DASH_CD_TIME)
		
		anim.play("dash")
		$DashSound.pitch_scale = randf_range(0.9, 1.1)
		$DashSound.play()
		allowed_to_move = false
		is_invincible = true
		available_dashes -= 1
		
		var particles = DASH_PARTICLES.instantiate()
		add_child(particles)
		particles.look_at((velocity + global_position).rotated(PI))
		particles.emitting = true
		
		velocity = global_position.direction_to(get_mouse_pos()).normalized() * DASH_STRENGTH
		return true
	return false
	
func _ready():
	super._ready()
	anim = $AnimatedSprite2D
	hurt_sound = $HurtSound

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		weapon.shoot()
	if Input.is_action_just_pressed("secondary"):
		if dash_duration_timer.time_left <= 0 and allowed_to_move and available_dashes > 0 and dash_duration_timer.time_left <= 0:
			perform_dash()

	#PlayerStats.cooldown = cooldown_timer.time_left

func _physics_process(delta):
	super._physics_process(delta)
	
	if dash_duration_timer.time_left > 0:
		move_and_slide()
	
	_weapon_rotation_process(weapon)
	
	if velocity.length() > 0 and not step_sound.playing and anim.animation != "dash":
		$StepTimer.start()
		step_sound.play()
	elif velocity.length() <= 0 or anim.animation == "dash":
		$StepTimer.stop()
		step_sound.stop()
	

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


func _on_step_timer_timeout() -> void:
	step_sound.pitch_scale = randf_range(0.85, 1.15)
