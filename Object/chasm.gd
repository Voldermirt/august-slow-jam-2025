extends Node2D

signal fallen_into

@export var default_sprite : Texture2D = null
@export var boom_sprite : Texture2D = null
@export var gateway_sprite : Texture2D = null
@export var cri_jun_sprite : Texture2D = null

func switch_to(game: Globals.GameList):
	match game:
		Globals.GameList.DEFAULT:
			if default_sprite:
				set_texture(default_sprite)
		Globals.GameList.BOOM:
			if boom_sprite:
				set_texture(boom_sprite)
		Globals.GameList.GATEWAY:
			if gateway_sprite:
				set_texture(gateway_sprite)
		Globals.GameList.CRITTER_JUNCTION:
			if cri_jun_sprite:
				set_texture(cri_jun_sprite)

func set_texture(texture):
	for child in get_children():
		if child is Sprite2D:
			child.texture = texture

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not (body is BasePlayer2D):
		return
	if body.health <= 0:
		return
	body._on_getting_hit(999999, true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	emit_signal("fallen_into")
	await get_tree().create_timer(0.25)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	
