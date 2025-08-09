extends Node2D


func switch_random_games():
	var chosen_game_index = randi() % GlobalEnums.GameList.size()
	switch_games(chosen_game_index)


func switch_games(game_index: GlobalEnums.GameList):
	var wrappers: Array[Node] = get_tree().get_nodes_in_group("switch_wrapper")
	for wrapper in wrappers:
		var switch_wrapper = wrapper as BaseWrapper
		switch_wrapper.switch_to(game_index)
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		switch_random_games()
		pass
		
