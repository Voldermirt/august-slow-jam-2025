extends Node
class_name MainRoom

enum Direction {UP, DOWN, LEFT, RIGHT}

@export_group("Cheat Codes")
@export var boom_code : Array[Direction]
@export var gateway_code : Array[Direction]
@export var critter_junction_code : Array[Direction]

@onready var zoom_anim := %ZoomAnim
@onready var view_3d := $Render3D
@onready var level = $Render2D/Level2D/Level

var zoom_out = false      # Are we zoomed/zooming out
var current_sequence = [] # Current cheat code input sequence

func _ready() -> void:
	Globals.level_change_requested.connect(change_level)

func string_to_dir(input : String):
	match input:
		"up":
			return Direction.UP
		"down":
			return Direction.DOWN
		"left":
			return Direction.LEFT
		"right":
			return Direction.RIGHT
		_:
			printerr("'%s' is not a valid direction!" % input)
			return Direction.DOWN

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom") and not zoom_out:
		# Zoom out
		view_3d.visible = true
		zoom_out = true
		zoom_anim.play("zoom")
	elif event.is_action_released("zoom") and zoom_out:
		# Zoom in
		zoom_out = false
		zoom_anim.play_backwards("zoom")
	
	# Get directional inputs
	for dir in ["up", "down", "left", "right"]:
		if event.is_action_pressed(dir):
			handle_directional_input(string_to_dir(dir), true)
			break
		elif event.is_action_released(dir):
			handle_directional_input(string_to_dir(dir), false)
			break
	

func _on_zoom_anim_animation_finished(anim_name: StringName) -> void:
	if not zoom_out:
		view_3d.visible = false

func change_level(new_level : PackedScene):
	level.queue_free()
	level = new_level.instantiate()
	$Render2D/Level2D.add_child(level)

###### CHEAT CODE INPUT ######
func handle_directional_input(dir : Direction, pressed : bool):
	if not zoom_out:
		current_sequence = []
		return
	if not pressed:
		return # I have this as a parameter just in case, I guess
	
	current_sequence.append(dir)
	var idx = len(current_sequence) - 1
	
	# Check if input matches any of the codes
	var matches = false
	for code in [boom_code, gateway_code, critter_junction_code]:
		if idx < len(code) and dir == code[idx]:
			matches = true
			if idx + 1 == len(code):
				print("Code successfully inputted!")
				Globals.switch_games(code_to_game(code))
				current_sequence = []
	if not matches:
		# Reset
		current_sequence = []

func code_to_game(code) -> Globals.GameList:
	if code == boom_code:
		return Globals.GameList.BOOM
	if code == gateway_code:
		return Globals.GameList.GATEWAY
	if code == critter_junction_code:
		return Globals.GameList.CRITTER_JUNCTION
	return Globals.GameList.DEFAULT
