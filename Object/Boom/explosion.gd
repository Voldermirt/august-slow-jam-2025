extends GPUParticles2D

var damage: int = 40

@onready var explosion_area: Area2D = $ExplosionArea2D
var knockback_force: float = 300
var knockback_duration: float = 0.5

func _ready():
	explosion_area.hide()
	
func _process(delta):
	if emitting and explosion_area.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		explosion_area.process_mode = ProcessMode.PROCESS_MODE_INHERIT
		explosion_area.show()


func _on_explosion_area_2d_body_entered(body: Node2D):
	if body is BoomObject2D:
		(body as BoomObject2D).explode()
	elif body is BaseEntity2D:
		(body as BaseEntity2D).knockback_applied(global_position.direction_to(body.global_position), knockback_force, knockback_duration)
		(body as BaseEntity2D)._on_getting_hit(damage, false)


func _on_ttl_timeout():
	queue_free()
