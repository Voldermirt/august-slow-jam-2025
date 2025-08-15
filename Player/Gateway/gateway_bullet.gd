extends CharacterBody2D

const Gateway := preload("res://Player/Gateway/gateway.tscn")

@export var speed := 500

var is_orange = false # Blue if false, orange if true
var direction := Vector2.RIGHT
var color : Color

func _ready() -> void:
	$Sprite2D.self_modulate = color
	Globals.game_changed.connect(game_changed)

func game_changed(_game):
	queue_free()

func _physics_process(delta: float) -> void:
	global_rotation = direction.angle()
	# Move the bullet and get the collision info
	var col = move_and_collide(direction * speed * delta)
	
	if col:
		# Spawn a portal
		var portal = Gateway.instantiate()
		portal.is_orange = is_orange
		portal.color = color
		Globals.get_2d_root().add_child(portal)
		portal.rotation = col.get_angle()
		portal.global_position = col.get_position()
		
		queue_free()
		
