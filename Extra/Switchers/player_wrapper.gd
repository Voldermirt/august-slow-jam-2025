extends SwitchWrapper2D

class_name PlayerWrapper2D

signal player_switched_games(players_newest_scene: BasePlayer2D)
signal ui_update_requested()
signal unlock_game(game: String)
signal player_death

func _process(delta):
	ui_update_requested.emit()

func _ready():
	super._ready()
	player_switched_games.emit(switching_scene as BasePlayer2D)
	# Connect unlock game signal from default
	get_child(0).connect("unlock_game", on_default_unlock_game)
	get_child(0).connect("death", on_player_death)
	
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
	
	#scene_to_replace = children[0]
	if scene_to_replace == null:
		assert(false, INVALID_CHILD_ERROR)
		return
	elif scene_to_replace.name == "DefaultPlayer2D":
		scene_to_replace.disconnect("unlock_game", on_default_unlock_game)

	previous_position = scene_to_replace.position
	match game:
		Globals.GameList.DEFAULT:
			if default_scene == null:
				return
			new_scene = default_scene.instantiate()
			new_scene.connect("death", on_player_death)
			new_scene.connect("unlock_game", on_default_unlock_game)
			new_scene.add_to_group("default")
			active_game = Globals.GameList.DEFAULT
		Globals.GameList.BOOM:
			if boom_scene == null:
				return
			new_scene = boom_scene.instantiate()
			new_scene.connect("death", on_player_death)
			new_scene.add_to_group("boom")
			active_game = Globals.GameList.BOOM
		Globals.GameList.GATEWAY:
			if gateway_scene == null:
				return
			new_scene = gateway_scene.instantiate()
			new_scene.connect("death", on_player_death)
			new_scene.add_to_group("gateway")
			active_game = Globals.GameList.GATEWAY
		Globals.GameList.CRITTER_JUNCTION:
			if critter_junction_scene == null:
				return
			new_scene = critter_junction_scene.instantiate()
			new_scene.connect("death", on_player_death)
			new_scene.add_to_group("critter_junction")
			active_game = Globals.GameList.CRITTER_JUNCTION
		_:
			push_error("Trying to switch to a non-existing game!")
			return 
	
	# Copy the data
	if new_scene is BaseEntity2D and scene_to_replace is BaseEntity2D:
		(new_scene as BaseEntity2D).retrieve_data(scene_to_replace as BaseEntity2D)
	
	# Deletes the previous scene and waits until it is deleted!
	scene_to_replace.queue_free()
	await get_tree().process_frame
	
	
	new_scene.global_position = previous_position
	add_child(new_scene)

func _on_child_entered_tree(node: Node):
	super._on_child_entered_tree(node)
	if switching_scene is BasePlayer2D:
		player_switched_games.emit(switching_scene as BasePlayer2D)
	else:
		push_error("Player Wrapper doesn't have the player scene?")

func on_default_unlock_game(game: String):
	emit_signal("unlock_game", game)

func on_player_death():
	emit_signal("player_death")
