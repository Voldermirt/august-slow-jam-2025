extends SwitchWrapper2D

signal button_on
signal button_off

# for button stuff

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
	elif scene_to_replace.name == "Button":
		scene_to_replace.disconnect("on", _on_button_on)
		scene_to_replace.disconnect("off", _on_button_off)

	previous_position = scene_to_replace.position
	
	match game:
		Globals.GameList.DEFAULT:
			new_scene = default_scene.instantiate()
			new_scene.add_to_group("default")
			active_game = Global.GameList.DEFAULT
		Globals.GameList.BOOM:
			new_scene = boom_scene.instantiate()
			new_scene.add_to_group("boom")
			active_game = Global.GameList.BOOM
		Globals.GameList.GATEWAY:
			new_scene = gateway_scene.instantiate()
			new_scene.on.connect(_on_button_on)
			new_scene.off.connect(_on_button_off)
			new_scene.add_to_group("gateway")
			active_game = Global.GameList.GATEWAY
		Globals.GameList.CRITTER_JUNCTION:
			new_scene = critter_junction_scene.instantiate()
			new_scene.add_to_group("critter_junction")
			active_game = Global.GameList.CRITTER_JUNCTION
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


func _on_button_on():
	emit_signal("button_on")

func _on_button_off():
	emit_signal("button_off")
