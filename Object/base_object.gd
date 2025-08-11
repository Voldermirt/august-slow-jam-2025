extends RigidBody2D

class_name BaseObject2D

func _ready():
	gravity_scale = 0
	linear_velocity = Vector2i.ZERO
	angular_velocity = 0
	
	
func _process(delta):
	if linear_velocity != Vector2.ZERO:
		pass
		
