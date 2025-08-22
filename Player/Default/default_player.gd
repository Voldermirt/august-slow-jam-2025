extends BasePlayer2D

# The default player game starts with
class_name DefaultPlayer2D

@onready var default_weapon: DefaultSword = $DefaultSword

func _ready():
	super._ready()
	anim = $AnimatedSprite2D
	hurt_sound = $HurtSound

#func save_json_data() -> JSON:
	#var super_data: JSON = super.save_json_data()
	#return super_data

func _physics_process(delta):
	super._physics_process(delta)
	if not default_weapon.is_attacking():
		_weapon_rotation_process(default_weapon)
