extends Node2D

signal fallen_into

@export var default_sprite : Texture2D = null
@export var boom_sprite : Texture2D = null
@export var gateway_sprite : Texture2D = null
@export var cri_jun_sprite : Texture2D = null

@onready var children = get_children()

func switch_to(game: Globals.GameList):
	match game:
		Globals.GameList.DEFAULT:
			if default_sprite:
				for child in children:
					if child is Sprite2D:
						child.texture = default_sprite
		Globals.GameList.BOOM:
			if boom_sprite:
				for child in children:
					if child is Sprite2D:
						child.texture = boom_sprite
		Globals.GameList.GATEWAY:
			if gateway_sprite:
				for child in children:
					if child is Sprite2D:
						child.texture = gateway_sprite
		Globals.GameList.CRITTER_JUNCTION:
			if cri_jun_sprite:
				for child in children:
					if child is Sprite2D:
						child.texture = cri_jun_sprite


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not (body is BasePlayer2D):
		return
	print(body)
	body._on_getting_hit(999999, true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	emit_signal("fallen_into")
	await get_tree().create_timer(0.25)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	
