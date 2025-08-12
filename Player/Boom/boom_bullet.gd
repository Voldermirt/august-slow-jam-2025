extends CharacterBody2D


@export var speed := 600

var direction := Vector2.RIGHT

func _ready() -> void:
	Globals.game_changed.connect(game_changed)

func game_changed(_game):
	queue_free()

func _physics_process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col = move_and_collide(direction * speed * delta)
	
	if col:
		queue_free()
		# Damage enemy (if it's an enemy)
		
