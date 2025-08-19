extends BaseUI

class_name GeneralUI

@onready var health_bar := $HealthBar

#var player_wrapper: PlayerWrapper2D
#var _current_player_scene: BasePlayer2D


func update_ui():
	if _current_player_scene != null:
		health_bar.max_value = _current_player_scene.BASE_MAX_HEALTH
		health_bar.value = _current_player_scene.health
