extends Node2D

class_name SwitchWrapper2D

const INVALID_CHILD_ERROR: String = "The wrapper MUST have a single child player/object scene that can be switched between games!"

@export var default_scene: PackedScene
@export var boom_scene: PackedScene
@export var gateway_scene: PackedScene
@export var critter_junction_scene: PackedScene


## Empty function to be overriden by the subclass
#func switch_to(game: Globals.GameList):
	#push_error("This is an abstract method, only should be overriden and called in the subclass")
	
func _ready():
	var children_nodes: Array[Node]
	
	if default_scene == null:
		push_error("No default export scene supplied")
	if boom_scene == null:
		push_error("No boom export scene supplied")
	if gateway_scene == null: 
		push_error("No gateway export scene supplied")
	if critter_junction_scene == null:
		push_error("No critter junction export scene supplied")
	
	# Makes sure that the Entity spawns with the correct starting data
	children_nodes = get_children()
	if children_nodes != null and children_nodes.size() == 1:
		if children_nodes[0] is BaseEntity2D:
			(children_nodes[0] as BaseEntity2D).set_spawn_data()


func switch_to(game: Globals.GameList):
	# Get all the children to make sure everything works
	var children: Array[Node]
	# The current scene to be replaced
	var scene_to_replace: Node2D
	# The new scene replacing the old one
	var new_scene: Node2D
	# The positin of the scene to be replaced
	var previous_position: Vector2
	
	
	if game < 0 or game > Globals.GameList.size():
		assert(false, "Not recognizing the game to switch to!")
		return
	
	children = get_children()
	if children.size() != 1:
		assert(false, INVALID_CHILD_ERROR)
		return
		
	scene_to_replace = children[0]
	if scene_to_replace == null:
		assert(false, INVALID_CHILD_ERROR)
		return

	previous_position = scene_to_replace.global_position
	
	match game:
		Globals.GameList.DEFAULT:
			new_scene = default_scene.instantiate()
			new_scene.add_to_group("default")
		Globals.GameList.BOOM:
			new_scene = boom_scene.instantiate()
			new_scene.add_to_group("boom")
		Globals.GameList.GATEWAY:
			new_scene = gateway_scene.instantiate()
			new_scene.add_to_group("gateway")
		Globals.GameList.CRITTER_JUNCTION:
			new_scene = critter_junction_scene.instantiate()
			new_scene.add_to_group("critter_junction")
		_:
			push_error("Trying to switch to a non-existing game!")
	
	# Copy the data
	if new_scene is BaseEntity2D and scene_to_replace is BaseEntity2D:
		(new_scene as BaseEntity2D).retrieve_data(scene_to_replace as BaseEntity2D)
	
	# Deletes the previous scene and waits until it is deleted!
	scene_to_replace.queue_free()
	await get_tree().process_frame
	
	
	new_scene.global_position = previous_position
	add_child(new_scene)
	
