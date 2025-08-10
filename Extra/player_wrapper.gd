extends BaseWrapper

class_name SwitchWrapper

const DEFAULT_PLAYER_SCENE: PackedScene = preload("res://Player/Default/default_player.tscn")
const DOOM_PLAYER_SCENE: PackedScene = preload("res://Player/Doom/doom_player.tscn")
const PORTAL_PLAYER_SCENE: PackedScene = preload("res://Player/Portal/portal_player.tscn")
const ANIMAL_CROSSING_SCENE: PackedScene = preload("res://Player/AnimalCrossing/ani_cross_player.tscn")

func switch_to(game: Globals.GameList):
	# Get all the children to make sure everything works
	var children: Array[Node]
	# The current scene to be replaced
	var player_to_replace: BasePlayer2D
	# The new scene replacing the old one
	var new_player_scene
	# The positin of the scene to be replaced
	var previous_position: Vector2
	
	
	if game < 0 or game > Globals.GameList.size():
		assert(false, "Not recognizing the game to switch to!")
		return
	
	children = get_children()
	if children.size() != 1:
		assert(false, INVALID_CHILD_ERROR)
		return
		
	player_to_replace = children[0] as BasePlayer2D
	if player_to_replace == null:
		assert(false, INVALID_CHILD_ERROR)
		return
		
	previous_position = player_to_replace.position
	player_to_replace.queue_free()
	match game:
		Globals.GameList.DEFAULT:
			new_player_scene = DEFAULT_PLAYER_SCENE.instantiate()
		Globals.GameList.DOOM:
			new_player_scene = DOOM_PLAYER_SCENE.instantiate()
		Globals.GameList.PORTAL:
			new_player_scene = PORTAL_PLAYER_SCENE.instantiate()
		Globals.GameList.ANIMAL_CROSSING:
			new_player_scene = ANIMAL_CROSSING_SCENE.instantiate()
		_:
			push_error("Trying to switch to a non-existing game!")
	add_child(new_player_scene)
	new_player_scene.position = previous_position
	
