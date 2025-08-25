extends Node2D

class_name MainLevel2D

signal unlock_game(game: String)

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

var active_game: Global.GameList = 0
var savefile_index: int = -1

# So that the entity knows which entity from JSON file to pull data from
func retrieve_savefile_index(index: int):
	savefile_index = index


func load_json_data():
	var data: Dictionary
	
	if Globals.temp_last_save.is_empty():
		push_error("Couldn't load data from the temporary save file variable in global!")
		return
	if savefile_index < 0:
		push_error("Couldn't load data because the entity hasn't been saved yet!")
		return
	#var debug = Globals.temp_last_save[0]
	if not Globals.temp_last_save.has(str(savefile_index)):
		push_error("Couldn't load data because the entity is not persent in the save file!")
		return
		
	data = Globals.temp_last_save[str(savefile_index)]
	
	# switch the game if it is different
	var prev_game = data.get("active_game")
		
	#if prev_game != null and prev_game != active_game:
	if prev_game != null:
		switch_to(int(prev_game))
		
	await get_tree().process_frame
	

func _ready() -> void:
	var global_scene: Global =  get_tree().get_first_node_in_group("global_scene")
	
	if global_scene != null:
		global_scene.save_game()
		#global_scene.game_changed.connect(switch_to)
	else:
		push_error("The main level could not retrieve the Global node on ready!")

func switch_to(game: Globals.GameList):
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
			active_game = 0
	active_game = game

func _on_first_chasm_fallen_into() -> void:
	emit_signal("unlock_game", "gateway")


#func _on_end_room_trip_wire_basically_body_entered(body: Node2D) -> void:
	#if body is BasePlayer2D:
		#$Rooms/Room15/Door.close()
