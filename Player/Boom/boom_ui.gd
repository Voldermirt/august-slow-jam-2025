extends Control

@onready var cooldown_bar := $CooldownBar
@onready var ammo_label := $AmmoCount

func _ready():
	update_ui()
	Globals.ui_update_requested.connect(update_ui)

func update_ui():
	cooldown_bar.max_value = PlayerStats.max_cooldown
	cooldown_bar.value = PlayerStats.cooldown
	ammo_label.text = " %s " % PlayerStats.ammo
