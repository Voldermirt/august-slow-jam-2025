extends BasePlayer2D

# The default player game starts with
class_name DefaultPlayer2D

@onready var default_weapon: DefaultWeapon2D = $DefaultWeapon2D

func _physics_process(delta):
	_player_movement_process()
	_weapon_rotation_process(default_weapon)
