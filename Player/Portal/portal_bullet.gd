extends CharacterBody2D

const Portal := preload("res://Player/Portal/portal.tscn")

@export var speed := 500

var is_orange = false # Blue if false, orange if true
var direction := Vector2.RIGHT

func _ready() -> void:
	if is_orange:
		pass
	else:
		pass

func _physics_process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col = move_and_collide(direction * speed * delta)
	
	if col:
		# Spawn a portal
		var portal = Portal.instantiate()
		portal.is_orange = is_orange
		Globals.get_2d_root().add_child(portal)
		portal.global_rotation = col.get_angle()
		portal.global_position = col.get_position()
		
		queue_free()
		
