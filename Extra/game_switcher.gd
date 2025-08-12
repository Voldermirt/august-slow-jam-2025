extends Node2D

# Switches the game by asking each switchable object to switch to a particular game
class_name GameSwitcher2D

var current_game_index: int = Globals.GameList.DEFAULT

func get_random_game():
	return randi() % Globals.GameList.size()
	
func switch_random_games():
	var chosen_game_index: int = get_random_game()
	while chosen_game_index == current_game_index:
		chosen_game_index = get_random_game()
	current_game_index = chosen_game_index
	switch_games(chosen_game_index)


func switch_games(game_index: Globals.GameList):
	var wrappers: Array[Node] = get_tree().get_nodes_in_group("switch_wrapper")
	for wrapper in wrappers:
		var switch_wrapper = wrapper as SwitchWrapper2D
		switch_wrapper.switch_to(game_index)
	Globals.signal_game_change(game_index)
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#switch_random_games()
		var new_idx = wrap(current_game_index + 1, 0, Globals.GameList.size())
		current_game_index = new_idx
		switch_games(new_idx)
		pass
		
