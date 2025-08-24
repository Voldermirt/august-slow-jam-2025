extends RigidBody2D

class_name BaseObject2D

#var prev_pos_debug: Vector2
const DAMP: float = 30

func _ready():
	gravity_scale = 0
	linear_velocity = Vector2i.ZERO
	angular_velocity = 0


func save_json_data() -> Dictionary:
	var base_data = {
		"global_position": global_position
	}
	return base_data

func load_json_data(data: Dictionary):
	global_position = str_to_var("Vector2" + data["global_position"])

#func _process(delta):
	#if linear_velocity != Vector2.ZERO:
		#pass
	#if prev_pos_debug != position:
		#var cur_pos_debug = position
		#pass
	#prev_pos_debug = position

func kill():
	var switch_wrapper: SwitchWrapper2D = get_parent() as SwitchWrapper2D
	if switch_wrapper != null:
		switch_wrapper.queue_free()
	else:
		queue_free()
		
func receive_damage(body: Node):
	pass
