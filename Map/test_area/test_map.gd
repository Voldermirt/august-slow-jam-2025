extends Node2D

@onready var boom_walls = preload("res://assets/sprites/boom_walls.png")
@onready var gateway_gun_walls = preload("res://assets/sprites/gateway_gun_walls.png")
@onready var critter_junction_walls = preload("res://assets/sprites/critter_junction_walls.png")

# Grabs the atlas of the tileset so the texture can be swapped out
@onready var walls_tileset_atlas = $TileMapLayer.get_tile_set().get_source(0)

func _ready() -> void:
	walls_tileset_atlas.texture = critter_junction_walls
