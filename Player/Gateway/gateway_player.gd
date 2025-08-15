extends BasePlayer2D

class_name GatewayPlayer2D

@onready var weapon := $GatewayGun


func _ready():
	super._ready()
	anim = $AnimatedSprite2D
	
func _physics_process(delta):
	super._physics_process(delta)
	_weapon_rotation_process(weapon)
