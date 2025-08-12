extends Control


@onready var health_bar := $HealthBar

func _ready() -> void:
	update_ui()
	Globals.ui_update_requested.connect(update_ui)

func update_ui():
	health_bar.max_value = PlayerStats.max_health
	health_bar.value = PlayerStats.health
