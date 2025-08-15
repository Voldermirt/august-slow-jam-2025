extends SwitchWrapper2D

class_name PlayerWrapper2D

signal player_switched_games(players_newest_scene: BasePlayer2D)
signal ui_update_requested()

func _process(delta):
	ui_update_requested.emit()

func _ready():
	super._ready()
	player_switched_games.emit(switching_scene as BasePlayer2D)
	
func switch_to(game: Globals.GameList):
	super.switch_to(game)

func _on_child_entered_tree(node: Node):
	super._on_child_entered_tree(node)
	if switching_scene is BasePlayer2D and is_node_ready():
		player_switched_games.emit(switching_scene as BasePlayer2D)
	else:
		push_error("Player Wrapper doesn't have the player scene?")
