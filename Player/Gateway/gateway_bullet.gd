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
		# Ensure it's a valid collision + adjust accordingly
		rotation = col.get_normal().angle() + PI
		await get_tree().physics_frame
		
		var left = $LeftFront.has_overlapping_bodies() and !$LeftSide.has_overlapping_bodies()
		var right = $RightFront.has_overlapping_bodies() and !$RightSide.has_overlapping_bodies()
		var col_pos = col.get_position()
		
		if left and not right:
			col_pos += Vector2(0, -12).rotated(rotation)
		elif right and not left:
			col_pos += Vector2(0, 12).rotated(rotation)
		elif not (left or right):
			queue_free()
			return
		
		# Spawn a portal
		var portal = Gateway.instantiate()
		portal.is_orange = is_orange
		portal.color = color
		Globals.get_2d_root().add_child(portal)
		portal.rotation = col.get_normal().angle() + PI / 2
		portal.global_position = col_pos
		
		queue_free()
		
