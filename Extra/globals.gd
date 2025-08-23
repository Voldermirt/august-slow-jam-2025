extends Node

# It's time for a GAME CHANGER
# I'm Sam Reich, and I've been here the WHOLE TIME
# (idk lmao)
signal game_changed(new_game : GameList)
signal level_change_requested(new_level : PackedScene)
signal start_loading_game

enum GameList {
	DEFAULT,
	BOOM,
	GATEWAY,
	CRITTER_JUNCTION
}

const SAVE_PATH = "user://last_save.json"

var current_game_index: int = GameList.DEFAULT
var temp_last_save: Dictionary
var can_switch = true

var zoom_out = false

@onready var current_bgm_track := $DefaultMusic

func _ready():
	var root: Node2D = get_2d_root()
	if root != null:
		root.ready.connect(save_game)
	
func set_zoom_out(new_zoom : bool) -> void:
	zoom_out = new_zoom
	set_bgm(current_game_index)

func _process(delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_accept"):
		switch_random_games()
	if OS.is_debug_build() and Input.is_action_pressed("interact"):
		Globals.load_game()

func save_game() -> bool:
	var file: FileAccess
	var last_save_json: JSON = JSON.new()
	var currently_saved_data: Dictionary = {}
	var currently_json_index: int = 0
	temp_last_save.clear()
	
	file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		save_entities(currently_saved_data, currently_json_index)
		
		file.store_string(JSON.stringify(currently_saved_data, "\n"))
		
		print("Successfully saved current data")
		return true
	else:
		push_error("Couldn't save the current data")
		return false

func save_entities(to_save_data: Dictionary, current_json_index: int) -> int:
	var objects: Array[Node] = get_tree().get_nodes_in_group("switch_wrapper")
	for object in objects: 
		if object is SwitchWrapper2D:
			var wrapper: SwitchWrapper2D = (object as SwitchWrapper2D)
			var retrieved_data: Dictionary = wrapper.save_json_data()
			to_save_data[current_json_index] = retrieved_data
			
			wrapper.retrieve_savefile_index(current_json_index)
			if not start_loading_game.is_connected(wrapper.load_json_data):
				start_loading_game.connect(wrapper.load_json_data)
			
		current_json_index += 1
	return current_json_index

func load_game():
	var file: FileAccess
	
	file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file != null:
		var text = file.get_as_text()
		temp_last_save = JSON.parse_string(text)
		start_loading_game.emit()
		
		# Make sure to delete all portals
		for gateway in get_tree().get_nodes_in_group("delete_on_load"):
			gateway.queue_free()
	pass

#func load_entities():
	#var entities: Array[Node] = get_tree().get_nodes_in_group("entity")
	#for entity in entities: 
		#if entity is BaseEntity2D:
			#pass

#func save_current_scene():
	#var packed_scene = PackedScene.new()
	#var current_scene = get_tree().get_current_scene()
	#packed_scene.pack(current_scene)
	#ResourceSaver.save(packed_scene, SAVE_PATH)


	#get_tree().call_deferred("change_scene_to_packed", packed_scene)
	
	#get_tree().change_scene_to_packed(load(SAVE_PATH))
	#await get_tree().process_frame


func get_2d_root() -> Node2D:
	var to_return: Node
	var tree = get_tree()
	var view_port_2D: Node = tree.get_first_node_in_group("2d_viewport")
	
	# Spawn on 2D viewport specifically
	if view_port_2D != null:
		to_return = view_port_2D.get_child(0)
	
	# If there's none, only spawn at root when debugging
	elif OS.is_debug_build():
		to_return = tree.root
	
	return to_return

func get_portal(orange):
	for portal in get_tree().get_nodes_in_group("portal_instance"):
		if portal is Portal and portal.is_orange == orange:
			return portal
	return null

func change_level(new_level : PackedScene):
	level_change_requested.emit(new_level)


func get_random_game() -> int:
	return randi() % GameList.size()
	
func switch_random_games():
	var chosen_game_index := get_random_game()
	while chosen_game_index == current_game_index:
		chosen_game_index = get_random_game()
	current_game_index = chosen_game_index
	switch_games(chosen_game_index)

func switch_games(game_index: GameList):
	if not can_switch:
		return
	var wrappers: Array[Node] = get_tree().get_nodes_in_group("switch_wrapper")
	current_game_index = game_index
	for wrapper in wrappers:
		wrapper.switch_to(game_index)
	game_changed.emit(game_index)
	set_bgm(game_index)

func set_bgm(game_index : GameList) -> void:
	# Change BGM
	create_tween().tween_property(current_bgm_track, "volume_db", -40, 1)
	var old_pos = current_bgm_track.get_playback_position()
	var new_track = current_bgm_track
	var music_node = $LowQualityMusic if zoom_out else self
	match game_index:
		GameList.DEFAULT:
			new_track = music_node.get_node("DefaultMusic")
		GameList.BOOM:
			new_track = music_node.get_node("BoomMusic")
		GameList.GATEWAY:
			new_track = music_node.get_node("GatewayMusic")
		GameList.CRITTER_JUNCTION:
			new_track = music_node.get_node("CriJunMusic")
	create_tween().tween_property(new_track, "volume_db", 0.0, 1)
	# Just to make sure
	new_track.seek(old_pos)
	current_bgm_track = new_track
