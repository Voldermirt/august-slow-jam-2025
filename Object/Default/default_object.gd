extends BaseObject2D

class_name DefaultObject2D

var break_player_knock_force: float = 50
var break_player_knock_duration: float = 0.2

func break_itself(body: Node):
	if body is BasePlayer2D:
		(body as BasePlayer2D).knockback_applied(global_position.direction_to(body.global_position), break_player_knock_force, break_player_knock_duration)
	collision_layer = 0
	collision_mask = 0
	await get_tree().process_frame
	
	var parent_wrapper: ObjectWrapper2D
	var parent_node = get_parent()
	if parent_node != null and parent_node is ObjectWrapper2D:
		parent_wrapper = parent_node as ObjectWrapper2D
	
		if parent_wrapper != null and parent_wrapper.crate_inside_object != null and parent_wrapper.crate_inside_object.can_instantiate():
			var inside_object = parent_wrapper.crate_inside_object.instantiate()
			if inside_object is Node2D:
				inside_object.global_position = global_position
				parent_wrapper.add_sibling(inside_object)
	
	$Sprite2D.play("break")
	$DestroySound.play()
	process_mode = Node.PROCESS_MODE_DISABLED
	#kill()

func _ready():
	super._ready()

#func _on_body_entered(body):
	#break_itself(body)

func receive_damage(body: Node):
	super.receive_damage(body)
	break_itself(body)
