extends BaseUI

class_name BoomUI

@onready var cooldown_bar := $CooldownBar
@onready var ammo_label := $AmmoCount
@onready var dash_count := $DashCount

func update_ui():
	cooldown_bar.max_value = PlayerStats.max_cooldown
	cooldown_bar.value = PlayerStats.cooldown
	ammo_label.text = str(PlayerStats.ammo)
	dash_count.text = str(PlayerStats.avail_dashes)
