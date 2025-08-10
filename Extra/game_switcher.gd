extends Node2D


var current_game_idx := 0

func switch_random_games():
	var chosen_game_index = randi() % Globals.GameList.size()
	switch_games(chosen_game_index)


func switch_games(game_index: Globals.GameList):
	var wrappers: Array[Node] = get_tree().get_nodes_in_group("switch_wrapper")
	for wrapper in wrappers:
		var switch_wrapper = wrapper as BaseWrapper
		switch_wrapper.switch_to(game_index)
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#switch_random_games()
		var new_idx = wrap(current_game_idx + 1, 0, Globals.GameList.size())
		current_game_idx = new_idx
		switch_games(new_idx)
		pass
		
