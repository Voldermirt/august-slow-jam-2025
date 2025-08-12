extends BasePlayer2D

class_name BoomPlayer2D

@onready var weapon := $BoomGun

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	_weapon_rotation_process(weapon)
