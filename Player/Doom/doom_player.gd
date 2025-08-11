extends BasePlayer2D
class_name DoomPlayer

@onready var default_weapon: DoomGun = $DoomGun

func _physics_process(delta):
	_player_movement_process()
	_weapon_rotation_process(default_weapon)
