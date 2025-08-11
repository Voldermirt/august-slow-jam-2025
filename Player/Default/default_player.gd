extends BasePlayer2D

# The default player game starts with
class_name DefaultPlayer2D

@onready var default_weapon: DefaultSword = $DefaultSword

func _physics_process(delta):
	_player_movement_process()
	if not default_weapon.is_attacking():
		_weapon_rotation_process(default_weapon)
