extends BaseObject2D

class_name BoomObject2D

@export var explosion_effect: PackedScene

func _ready():
	super._ready()

#func _process(delta):
	#if OS.is_debug_build() and Input.is_key_pressed(KEY_Q):
		#explode()

func explode():
		var explosion = explosion_effect.instantiate() as GPUParticles2D
		if explosion != null:
			explosion.finished.connect(kill)
			var parent: Node = get_parent()
			if parent != null:
				parent.add_sibling(explosion)
				explosion.global_position = self.global_position
			explosion.emitting = true
		kill()

func receive_damage(body: Node):
	super.receive_damage(body)
	explode()

#func _on_body_entered(body):
	#explode()


#func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#pass # Replace with function body.
