extends BasePlayer2D

class_name PortalPlayer

@onready var portal_gun: PortalGun = $PortalGun

func _physics_process(delta):
	_player_movement_process()
	_weapon_rotation_process(portal_gun)
