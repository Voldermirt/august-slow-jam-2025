extends Node

class_name SwitchWrapper2D

const INVALID_CHILD_ERROR: String = "The wrapper MUST have a single child player/object scene that can be switched between games!"

@export var default_scene: PackedScene
@export var boom_scene: PackedScene
@export var gateway_scene: PackedScene
@export var critter_junction_scene: PackedScene

var switching_scene: Node
var active_game: Globals.GameList
# Is used to map the data from the JSON save file 
var savefile_index: int = -1

## Empty function to be overriden by the subclass
#func switch_to(game: Globals.GameList):
	#push_error("This is an abstract method, only should be overriden and called in the subclass")
	
func _ready():
	
	if default_scene == null:
		push_error("No default export scene supplied")
	if boom_scene == null:
		push_error("No boom export scene supplied")
	if gateway_scene == null: 
		push_error("No gateway export scene supplied")
	if critter_junction_scene == null:
		push_error("No critter junction export scene supplied")
		
	
	if switching_scene is BaseEntity2D:
		(switching_scene as BaseEntity2D).set_spawn_data()
	
	
func save_json_data() -> Dictionary:
	var scene_data: Dictionary = {}
	
	#if switching_scene != null and switching_scene.has_method("save_json_data"):
	if switching_scene == null:
		push_error("The entity to be saved is missing in its wrapper!")
		return {}
	if switching_scene.has_method("save_json_data"):
		scene_data = switching_scene.save_json_data()
		#push_error("The entity to be saved doesn't have save method!")
		#return {}
		
	scene_data["active_game"] = active_game
	if switching_scene is BaseCollectable2D:
		scene_data["process_mode"] = switching_scene.process_mode
	return scene_data
	
# So that the entity knows which entity from JSON file to pull data from
func retrieve_savefile_index(index: int):
	savefile_index = index
	
func load_json_data():
	var data: Dictionary
	
	
	if switching_scene == null:
		push_error("The entity to be loaded is missing in its wrapper!")
		return 
	

	if Globals.temp_last_save.is_empty():
		push_error("Couldn't load data from the temporary save file variable in global!")
		return
		
	if savefile_index < 0:
		push_error("Couldn't load data because the entity hasn't been saved yet!")
		return
	#var debug = Globals.temp_last_save[0]
	if not Globals.temp_last_save.has(str(savefile_index)):
		push_error("Couldn't load data because the entity is not persent in the save file!")
		return
		
	data = Globals.temp_last_save[str(savefile_index)]
	
	# switch the game if it is different
	var prev_game = data.get("active_game")
	
	if switching_scene is BaseCollectable2D:
		pass
		
	#if prev_game != null and prev_game != active_game:
	if prev_game != null:
		switch_to(int(prev_game))
		
	await get_tree().process_frame
	
	if switching_scene is BaseCollectable2D:
		var pm = data.get("process_mode")
		if pm != null:
			switching_scene.process_mode = int(pm)
			#if pm != ProcessMode.PROCESS_MODE_DISABLED and switching_scene.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
			if switching_scene.process_mode != ProcessMode.PROCESS_MODE_DISABLED:
				switching_scene.set_deferred("monitoring", true)
				switching_scene.show()
		else:
			pass
		
	if switching_scene.has_method("load_json_data"):
		switching_scene.load_json_data(data)

func switch_to(game: Globals.GameList):
	# Get all the children to make sure everything works
	#var children: Array[Node]
	# The current scene to be replaced
	var scene_to_replace: Node
	# The new scene replacing the old one
	var new_scene: Node
	# The positin of the scene to be replaced
	var previous_position: Vector2
	
	if active_game == game:
		print("Trying to switch to the game that is already in use, aborting")
		return
	
	if game < 0 or game > Globals.GameList.size():
		assert(false, "Not recognizing the game to switch to!")
		return
	
	#children = get_children()
	#if children.size() != 1:
		#assert(false, INVALID_CHILD_ERROR)
		#return
		#
	
	scene_to_replace = switching_scene
	if scene_to_replace is BaseCollectable2D:
		pass
	
	#scene_to_replace = children[0]
	if scene_to_replace == null:
		assert(false, INVALID_CHILD_ERROR)
		return

	previous_position = scene_to_replace.position
	
	match game:
		Globals.GameList.DEFAULT:
			if default_scene == null:
				return
			new_scene = default_scene.instantiate()
			new_scene.add_to_group("default")
			active_game = Globals.GameList.DEFAULT
		Globals.GameList.BOOM:
			if boom_scene == null:
				return
			new_scene = boom_scene.instantiate()
			new_scene.add_to_group("boom")
			active_game = Globals.GameList.BOOM
		Globals.GameList.GATEWAY:
			if gateway_scene == null:
				return
			new_scene = gateway_scene.instantiate()
			new_scene.add_to_group("gateway")
			
			active_game = Globals.GameList.GATEWAY
		Globals.GameList.CRITTER_JUNCTION:
			if critter_junction_scene == null:
				return
			new_scene = critter_junction_scene.instantiate()
			new_scene.add_to_group("critter_junction")
			active_game = Globals.GameList.CRITTER_JUNCTION
		_:
			push_error("Trying to switch to a non-existing game!")
			return 
	
	# Copy the data
	if new_scene is BaseEntity2D and scene_to_replace is BaseEntity2D:
		(new_scene as BaseEntity2D).retrieve_data(scene_to_replace as BaseEntity2D)
		
	# Keep certain collectables disabled if they already were
	if new_scene is BaseCollectable2D and scene_to_replace is BaseCollectable2D and scene_to_replace.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		(new_scene as BaseCollectable2D).hide()
		(new_scene as BaseCollectable2D).process_mode = Node.PROCESS_MODE_DISABLED
	
	# Deletes the previous scene and waits until it is deleted!
	scene_to_replace.queue_free()
	await get_tree().process_frame
	
	
	new_scene.global_position = previous_position
	add_child(new_scene)
	


func _on_child_entered_tree(node: Node):
	
	# REMEMBER THIS
	switching_scene = node
	
	if switching_scene is BaseCollectable2D:
		pass
	
	## Makes sure that the Entity spawns with the correct starting data
	#if switching_scene.is_in_group("default"):
		#active_game = Globals.GameList.DEFAULT
	#elif switching_scene.is_in_group("boom"):
		#active_game = Globals.GameList.BOOM
	#elif switching_scene.is_in_group("gateway"):
		#active_game = Globals.GameList.GATEWAY
	#elif switching_scene.is_in_group("critter_junction"):
		#active_game = Globals.GameList.CRITTER_JUNCTION
	#else:
		#active_game = Globals.GameList.DEFAULT
		#print(name)
		#push_error(str("Switch wrapper couldn't identify the game of the child scene, setting to ", active_game))

	#else:
		#push_error("The switch wrapper has more than one scene upon wrapper's creation!")

	
