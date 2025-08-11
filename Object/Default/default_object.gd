extends BaseObject2D

class_name DefaultObject2D

@export var inside_object_scene: PackedScene

var break_player_knock_force: float = 50
var break_player_knock_duration: float = 0.2

func break_itself(body: Node):
	if body is BasePlayer2D:
		(body as BasePlayer2D).knockback_applied(global_position.direction_to(body.global_position), break_player_knock_force, break_player_knock_duration)
	collision_layer = 0
	collision_mask = 0
	await get_tree().process_frame
	
	var parent_node = get_parent()
	if inside_object_scene != null and inside_object_scene.can_instantiate() and parent_node != null:
		var inside_object = inside_object_scene.instantiate()
		if inside_object is Node2D:
			inside_object.global_position = global_position
			parent_node.add_child(inside_object)
		else:
			inside_object.queue_free()
		queue_free()
	else:
		queue_free()

func _ready():
	super._ready()


func _on_area_2d_body_entered(body: Node):
	break_itself(body)
