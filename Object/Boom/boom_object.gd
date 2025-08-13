extends BaseObject2D

class_name BoomObject2D

@export var explosion_effect: PackedScene

func _ready():
	super._ready()

func _process(delta):
	if OS.is_debug_build() and Input.is_key_pressed(KEY_Q):
		explode()

func explode():
		var explosion = explosion_effect.instantiate() as GPUParticles2D
		if explosion != null:
			explosion.finished.connect(kill)
			add_child(explosion)
			explosion.emitting = true
		#queue_free()
