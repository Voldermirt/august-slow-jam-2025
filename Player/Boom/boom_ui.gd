extends GeneralUI

class_name BoomUI

@onready var cooldown_bar := $CooldownBar
@onready var ammo_label := $AmmoCount

func update_ui():
	pass
	#cooldown_bar.max_value = _current_player_scene.max_cooldown
	#cooldown_bar.value = _current_player_scene.cooldown
	#ammo_label.text = " %s " % _current_player_scene.ammo
