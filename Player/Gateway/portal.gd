extends Area2D
class_name Portal

var is_orange = false # Blue if false, orange if true
var color : Color
var just_teleported := false

func _ready() -> void:
	$Sprite2D.self_modulate = color
	Globals.game_changed.connect(game_changed)

func game_changed(_game):
	queue_free()

func teleport(body):
	body.global_position = $TeleportTarget.global_position
	just_teleported = true

func _on_body_entered(body: Node2D) -> void:
	if just_teleported:
		# Don't want an immediate return trip
		just_teleported = false
		return
		
	var other_portal = Globals.get_portal(!is_orange)
	if not other_portal: # Make sure there IS another portal
		return
	
	other_portal.teleport(body)
	
