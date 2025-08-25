extends BaseCollectable2D

class_name DefaultCollectable2D

const DEFAULT_VALUE = 2

func get_value():
	return DEFAULT_VALUE
	

func _ready() -> void:
	super._ready()
	pickup_sound = $PickupSound
