extends Node

# It's time for a GAME CHANGER
# I'm Sam Reich, and I've been here the WHOLE TIME
# (idk lmao)
signal game_changed(new_game : GameList)
signal level_change_requested(new_level : PackedScene)

enum GameList {
	DEFAULT,
	BOOM,
	GATEWAY,
	CRITTER_JUNCTION
}

var current_game_index: int = GameList.DEFAULT


func _process(delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_accept"):
		switch_random_games()

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
	var wrappers: Array[Node] = get_tree().get_nodes_in_group("switch_wrapper")
	for wrapper in wrappers:
		var switch_wrapper = wrapper as SwitchWrapper2D
		switch_wrapper.switch_to(game_index)
	game_changed.emit(game_index)
	
