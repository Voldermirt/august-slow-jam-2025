extends Control

@onready var health_bar := $HealthBar

var player_wrapper: PlayerWrapper2D

func _ready():
	player_wrapper = get_tree().get_first_node_in_group("player_wrapper")
	if player_wrapper == null:
		push_error("UI cannot access the player!")
	else:
		player_wrapper.ui_update_requested.connect(update_ui)

func update_ui(player: BasePlayer2D):
	if player != null:
		health_bar.max_value = player.BASE_MAX_HEALTH
		health_bar.value = player.health
