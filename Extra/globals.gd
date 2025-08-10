extends Node

# It's time for a GAME CHANGER
# I'm Sam Reich, and I've been here the WHOLE TIME
# (sorry lmao)
signal game_changed(new_game : GameList)

enum GameList {
	DEFAULT,
	DOOM,
	PORTAL,
	ANIMAL_CROSSING
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
