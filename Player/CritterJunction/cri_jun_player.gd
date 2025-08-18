extends BasePlayer2D

class_name CriJunPlayer2D

@onready var weapon := $Tools

func _ready():
	super._ready()
	
func _physics_process(delta):
	super._physics_process(delta)
	_weapon_rotation_process(weapon)
