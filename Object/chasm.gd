extends Node2D

@export var default_sprite : Texture2D = null
@export var boom_sprite : Texture2D = null
@export var gateway_sprite : Texture2D = null
@export var cri_jun_sprite : Texture2D = null

func switch_to(game: Globals.GameList):
	match game:
		Globals.GameList.DEFAULT:
			if default_sprite:
				$Sprite2D.texture = default_sprite
		Globals.GameList.BOOM:
			if boom_sprite:
				$Sprite2D.texture = boom_sprite
		Globals.GameList.GATEWAY:
			if gateway_sprite:
				$Sprite2D.texture = gateway_sprite
		Globals.GameList.CRITTER_JUNCTION:
			if cri_jun_sprite:
				$Sprite2D.texture = cri_jun_sprite


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not (body is BasePlayer2D):
		return
	
	body._on_getting_hit(999999, true)
