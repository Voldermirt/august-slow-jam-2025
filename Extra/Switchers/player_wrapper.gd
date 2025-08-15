extends SwitchWrapper2D

class_name PlayerWrapper2D

signal player_switched_games(players_newest_game: Globals.GameList)
signal ui_update_requested(player_scene: BasePlayer2D)

func _process(delta):
	ui_update_requested.emit(switching_scene)

func switch_to(game: Globals.GameList):
	super.switch_to(game)
	player_switched_games.emit()

func _on_child_entered_tree(node: Node):
	super._on_child_entered_tree(node)
	if switching_scene is BasePlayer2D:
		ui_update_requested.emit(switching_scene as BasePlayer2D)
	else:
		push_error("Player Wrapper doesn't have the player scene?")
	
