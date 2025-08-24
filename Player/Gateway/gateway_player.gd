extends BasePlayer2D

class_name GatewayPlayer2D

@onready var weapon := $GatewayGun
@onready var step_sound := $FootstepSound

func _ready():
	super._ready()
	anim = $AnimatedSprite2D

	
func load_json_data(data: Dictionary):
	super.load_json_data(data)


func _physics_process(delta):
	super._physics_process(delta)
	_weapon_rotation_process(weapon)
	if velocity.length() > 0 and not step_sound.playing:
		$StepTimer.start()
		step_sound.play()
	elif velocity.length() <= 0:
		$StepTimer.stop()
		step_sound.stop()


func _on_step_timer_timeout() -> void:
	step_sound.pitch_scale = randf_range(0.85, 1.15)
