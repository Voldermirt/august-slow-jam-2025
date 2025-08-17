extends Node2D


@export var default_tiles : Texture2D
@export var boom_tiles : Texture2D
@export var gateway_tiles : Texture2D
@export var cri_jun_tiles : Texture2D

# Grabs the atlas of the tileset so the texture can be swapped out
@onready var tileset_atlas = $TileMapLayer.get_tile_set().get_source(0)

func _ready() -> void:
	pass

func switch_to(game : Globals.GameList):
	match game:
		Globals.GameList.DEFAULT:
			tileset_atlas.texture = default_tiles
		Globals.GameList.BOOM:
			tileset_atlas.texture = boom_tiles
		Globals.GameList.GATEWAY:
			tileset_atlas.texture = gateway_tiles
		Globals.GameList.CRITTER_JUNCTION:
			tileset_atlas.texture = cri_jun_tiles
		_:
			push_error("Trying to switch to a non-existing game!")
