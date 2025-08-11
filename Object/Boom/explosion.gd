extends GPUParticles2D

@onready var explosion_area: Area2D = $ExplosionArea2D
var knockback_force: float = 700
var knockback_duration: float = 0.5

func _ready():
	explosion_area.hide()
	
func _process(delta):
	if emitting and explosion_area.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		explosion_area.process_mode = ProcessMode.PROCESS_MODE_INHERIT
		explosion_area.show()


func _on_explosion_area_2d_body_entered(body: Node2D):
	if body is BasePlayer2D:
		(body as BasePlayer2D).knockback_applied(global_position.direction_to(body.global_position), knockback_force, knockback_duration)
		
