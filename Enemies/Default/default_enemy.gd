extends BaseEnemy2D

class_name DefaultEnemy2D

func _ready() -> void:
	super._ready()
	anim = $AnimatedSprite2D
	death_sound = $DeathSound
	hurt_sound = $HurtSound
