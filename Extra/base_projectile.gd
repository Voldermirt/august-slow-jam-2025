extends CharacterBody2D

class_name BaseProjectile2D

@export var speed := 600

var damage: float = 10

var direction := Vector2.RIGHT

func _ready() -> void:
	Globals.game_changed.connect(game_changed)
	#if (collision_mask & BasePlayer2D.ENEMY_LAYER_NUMER) == 0:
		#collision_mask += BasePlayer2D.ENEMY_LAYER_NUMER

func game_changed(_game):
	queue_free()
