extends Node2D

class_name SwitchWrapper2D

const INVALID_CHILD_ERROR: String = "The wrapper MUST have a single child player/object scene that can be switched between games!"

@export var default_scene: PackedScene
@export var boom_scene: PackedScene
@export var gateway_scene: PackedScene
@export var critter_junction_scene: PackedScene

## Empty function to be overriden by the subclass
#func switch_to(game: GlobalEnums.GameList):
	#push_error("This is an abstract method, only should be overriden and called in the subclass")


func switch_to(game: GlobalEnums.GameList):
	# Get all the children to make sure everything works
	var children: Array[Node]
	# The current scene to be replaced
	var scene_to_replace: BasePlayer2D
	# The new scene replacing the old one
	var new_scene
	# The positin of the scene to be replaced
	var previous_position: Vector2
	
	
	if game < 0 or game > GlobalEnums.GameList.size():
		assert(false, "Not recognizing the game to switch to!")
		return
	
	children = get_children()
	if children.size() != 1:
		assert(false, INVALID_CHILD_ERROR)
		return
		
	scene_to_replace = children[0] as BasePlayer2D
	if scene_to_replace == null:
		assert(false, INVALID_CHILD_ERROR)
		return
		
	previous_position = scene_to_replace.position
	scene_to_replace.queue_free()
	match game:
		GlobalEnums.GameList.DEFAULT:
			new_scene = default_scene.instantiate()
		GlobalEnums.GameList.BOOM:
			new_scene = boom_scene.instantiate()
		GlobalEnums.GameList.GATEWAY:
			new_scene = gateway_scene.instantiate()
		GlobalEnums.GameList.CRITTER_JUNCTION:
			new_scene = critter_junction_scene.instantiate()
		_:
			push_error("Trying to switch to a non-existing game!")
	add_child(new_scene)
	new_scene.position = previous_position
	
