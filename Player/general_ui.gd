extends Control

class_name GeneralUI

@onready var health_bar := $HealthBar

var player_wrapper: PlayerWrapper2D
var _current_player_scene: BasePlayer2D

func _ready():
	player_wrapper = get_tree().get_first_node_in_group("player_wrapper")
	if player_wrapper == null:
		push_error("UI cannot access the player!")
	else:
		player_wrapper.ui_update_requested.connect(update_ui)
		player_wrapper.player_switched_games.connect(replace_current_player_scene)

func replace_current_player_scene(new_scene: BasePlayer2D):
	_current_player_scene = new_scene

func update_ui():
	if _current_player_scene != null:
		health_bar.max_value = _current_player_scene.BASE_MAX_HEALTH
		health_bar.value = _current_player_scene.health
