extends SwitchWrapper2D

class_name ObjectWrapper2D

"""
	Object wrapper specifically for storing Critter Junctioninfo between Games
"""

# persistent info for Critter Junction
enum state {PLOT, SAPLING, TREE}
enum fruit {APPLE, ORANGE, CHERRY, PEACH, PEAR}

var cri_jun_state: state
var cri_jun_fruit: fruit
var cri_jun_made_fruit: bool = false

@export var crate_inside_object: PackedScene

# custom switch_to which

func switch_to(game: Globals.GameList):
	# Get all the children to make sure everything works
	#var children: Array[Node]
	# The current scene to be replaced
	var scene_to_replace: Node
	# The new scene replacing the old one
	var new_scene: Node
	# The positin of the scene to be replaced
	var previous_position: Vector2
	
	
	if game < 0 or game > Globals.GameList.size():
		assert(false, "Not recognizing the game to switch to!")
		return
	
	#children = get_children()
	#if children.size() != 1:
		#assert(false, INVALID_CHILD_ERROR)
		#return
		#
	
	scene_to_replace = switching_scene 
	
	#scene_to_replace = children[0]
	if scene_to_replace == null:
		assert(false, INVALID_CHILD_ERROR)
		return
	elif scene_to_replace.name == "CriJunObject2D":
		# Snatch the fruit and current state of the plant and if its made fruit
		var tree = get_child(0)
		cri_jun_fruit = tree.fruit_type
		cri_jun_state = tree.current_state
		cri_jun_made_fruit = tree.made_fruit

	previous_position = scene_to_replace.position
	
	match game:
		Globals.GameList.DEFAULT:
			new_scene = default_scene.instantiate()
			new_scene.add_to_group("default")
			active_game = Globals.GameList.DEFAULT
		Globals.GameList.BOOM:
			new_scene = boom_scene.instantiate()
			new_scene.add_to_group("boom")
			active_game = Globals.GameList.BOOM
		Globals.GameList.GATEWAY:
			new_scene = gateway_scene.instantiate()
			new_scene.add_to_group("gateway")
			active_game = Globals.GameList.GATEWAY
		Globals.GameList.CRITTER_JUNCTION:
			new_scene = critter_junction_scene.instantiate()
			active_game = Globals.GameList.CRITTER_JUNCTION
			# Load the saved state and fruit into the cri jun scene
				# grow the tree if switching back to scene with a sapling
			if cri_jun_state == state.SAPLING:
				new_scene.current_state = state.TREE
			else:
				new_scene.current_state = cri_jun_state
			
			new_scene.fruit_type = cri_jun_fruit
			new_scene.made_fruit = cri_jun_made_fruit
			new_scene.add_to_group("critter_junction")
		_:
			push_error("Trying to switch to a non-existing game!")
	
	
	# Deletes the previous scene and waits until it is deleted!
	scene_to_replace.queue_free()
	await get_tree().process_frame
	
	
	new_scene.global_position = previous_position
	add_child(new_scene)
	
	
### DEBUG
@onready var last_pos = get_child(0).global_position

func _process(delta: float) -> void:
	if not get_child(0) is Node2D:
		return
	if get_child(0).global_position != last_pos:
		print("Position changed: %s, Name: %s, Parent: %s" % [get_child(0).global_position, get_child(0).name, get_parent().name])
	last_pos = get_child(0).global_position
