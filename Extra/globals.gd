extends Node

#class_name Globals

enum GameList {
	DEFAULT,
	DOOM,
	PORTAL,
	ANIMAL_CROSSING
}

func get_2d_root() -> Node2D:
	return get_tree().get_first_node_in_group("2d_viewport").get_child(0)
