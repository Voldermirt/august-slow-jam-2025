extends BasePlayer2D

# The default player game starts with
class_name DefaultPlayer2D

@onready var default_weapon: DefaultWeapon2D = $DefaultWeapon2D


func _ready():
	super._ready()
	pass
	
func _physics_process(delta):
	super._physics_process(delta)
	_weapon_rotation_process(default_weapon)
