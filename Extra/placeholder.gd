extends Node2D



func save_json_data() -> Dictionary:
	var base_data = {
		"global_position": global_position
	}
	return base_data

func load_json_data(data: Dictionary):
	global_position = str_to_var("Vector2" + data["global_position"])
