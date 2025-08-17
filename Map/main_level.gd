extends Node2D

@export_group("Tiles")
@export var default_tiles : Texture2D
@export var boom_tiles : Texture2D
@export var gateway_tiles : Texture2D
@export var cri_jun_tiles : Texture2D

@export_group("Background Colors")
@export var default_color : Color
@export var boom_color : Color
@export var gateway_color : Color
@export var cri_jun_color : Color


# Grabs the atlas of the tileset so the texture can be swapped out
@onready var tileset_atlas = $TileMapLayer.get_tile_set().get_source(0)
@onready var bg_sprite = $Background/Sprite2D

func _ready() -> void:
	pass

func switch_to(game : Globals.GameList):
	match game:
		Globals.GameList.DEFAULT:
			tileset_atlas.texture = default_tiles
			bg_sprite.self_modulate = default_color
		Globals.GameList.BOOM:
			tileset_atlas.texture = boom_tiles
			bg_sprite.self_modulate = boom_color
		Globals.GameList.GATEWAY:
			tileset_atlas.texture = gateway_tiles
			bg_sprite.self_modulate = gateway_color
		Globals.GameList.CRITTER_JUNCTION:
			tileset_atlas.texture = cri_jun_tiles
			bg_sprite.self_modulate = cri_jun_color
		_:
			push_error("Trying to switch to a non-existing game!")
