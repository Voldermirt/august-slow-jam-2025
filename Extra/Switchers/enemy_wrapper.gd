extends SwitchWrapper2D

signal cri_jun_request_fulfilled

enum fruit {APPLE, ORANGE, CHERRY, PEACH, PEAR}

@export var cri_jun_requested_fruit: fruit
@export var cri_jun_requested_count: int
var cri_jun_fulfilled := false


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
	elif scene_to_replace.name == "CritterJunctionEnemy2D":
		# Snatch variable values
		var villager = get_child(0)
		cri_jun_requested_fruit = villager.requested_fruit
		cri_jun_requested_count = villager.requested_count
		cri_jun_fulfilled = villager.fulfilled
		# disconnect signal
		scene_to_replace.disconnect("fulfilled_request", _on_cri_jun_fulfilled_request)
		

	previous_position = scene_to_replace.position
	
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
			
			# Load stored variable values into Villager
			new_scene.requested_fruit = cri_jun_requested_fruit
			new_scene.requested_count = cri_jun_requested_count
			new_scene.fulfilled = cri_jun_fulfilled
			# connect signal
			new_scene.fulfilled_request.connect(_on_cri_jun_fulfilled_request)
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

func _on_cri_jun_fulfilled_request():
	emit_signal("cri_jun_request_fulfilled")
