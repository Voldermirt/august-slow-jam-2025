extends Area2D
class_name Portal

var is_orange = false # Blue if false, orange if true
var color : Color
var just_teleported := false

@onready var particles := $CPUParticles2D

func _ready() -> void:
	$AnimatedSprite2D.self_modulate = color
	particles.color = color
	Globals.game_changed.connect(game_changed)

func _process(delta: float) -> void:
	global_rotation_degrees = snappedi(global_rotation_degrees, 90)

func game_changed(_game):
	queue_free()

func teleport(body):
	if body is RigidBody2D:
		PhysicsServer2D.body_set_state(
			body.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			Transform2D.IDENTITY.translated($ObjectTeleportTarget.global_position))
	else:
		body.global_position = $PlayerTeleportTarget.global_position
	particles.emitting = true
	just_teleported = true
	$TeleportSound.play()
	await get_tree().create_timer(1).timeout
	just_teleported = false

func _on_body_entered(body: Node2D) -> void:
	if just_teleported:
		# Don't want an immediate return trip
		return
		
	var other_portal = Globals.get_portal(!is_orange)
	if not other_portal: # Make sure there IS another portal
		return
	
	other_portal.teleport(body)
	
