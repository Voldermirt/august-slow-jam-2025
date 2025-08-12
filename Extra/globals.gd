extends Node

# It's time for a GAME CHANGER
# I'm Sam Reich, and I've been here the WHOLE TIME
# (idk lmao)
signal game_changed(new_game : GameList)
signal level_change_requested(new_level : PackedScene)
signal ui_update_requested()

enum GameList {
	DEFAULT,
	BOOM,
	GATEWAY,
	CRITTER_JUNCTION
}

# The game switcher should maybe be merged into this object?
# Or maybe this object shouldn't exist at all and I'm going about it all wrong?
# Eh, as long as it works I guess
func signal_game_change(new_game : GameList):
	game_changed.emit(new_game)

func get_2d_root() -> Node2D:
	return get_tree().get_first_node_in_group("2d_viewport").get_child(0)

func get_portal(orange):
	for portal in get_tree().get_nodes_in_group("portal_instance"):
		if portal is Portal and portal.is_orange == orange:
			return portal
	return null

func change_level(new_level : PackedScene):
	level_change_requested.emit(new_level)
