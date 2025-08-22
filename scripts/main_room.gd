extends Node
class_name MainRoom

enum Direction {UP, DOWN, LEFT, RIGHT}

@export_group("Cheat Codes")
@export var default_code : Array[Direction]
@export var boom_code : Array[Direction]
@export var gateway_code : Array[Direction]
@export var critter_junction_code : Array[Direction]

# Array of currently available codes, default code is available at the beginning
var available_codes: = [default_code]

@onready var zoom_anim := %ZoomAnim
@onready var view_2d := $ScreenEffects/EffectViewport/Render2D
@onready var view_3d := $Render3D
@onready var level = $ScreenEffects/EffectViewport/Render2D/Level2D/Level

# Game cases are unique identifiers already

var zoom_out = false      # Are we zoomed/zooming out
var current_sequence = [] # Current cheat code input sequence


# Shader variables
@export_group("Glitch effect")
@export var glitch_curve : Curve
@export var max_glitch := 600
@export var glitch_seconds := 1.0
var glitch_spin_ratio = 1.0
var glitch_rotation := 0.0
var current_glitch_time := 0.0
var glitching := false
var min_glitch := 0

var selected_game : Globals.GameList

func _ready() -> void:
	Globals.level_change_requested.connect(change_level)
	view_2d.material.set_shader_parameter("offset", 0.0)

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
		get_tree().paused = true
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
		get_tree().paused = false

func change_level(new_level : PackedScene):
	level.queue_free()
	level = new_level.instantiate()
	$ScreenEffects/EffectViewport/Render2D/Level2D.add_child(level)
	

func _process(delta: float) -> void:
	
	### GLITCH ANIMATION ###
	# Rotation
	glitch_rotation = wrap(glitch_rotation + delta * glitch_spin_ratio, 0.0, 1.0)
	view_2d.material.set_shader_parameter("rotation_ratio", glitch_rotation)
	# Intensity
	if glitching:
		current_glitch_time = clamp(current_glitch_time + delta / glitch_seconds, 0.0, 1.0)
	else:
		current_glitch_time = clamp(current_glitch_time - delta / glitch_seconds, 0.0, 1.0)
	
	var intensity = max(glitch_curve.sample(current_glitch_time) * max_glitch, min_glitch)
	view_2d.material.set_shader_parameter("offset", int(intensity))
	
	if current_glitch_time >= 1.0:
		Globals.switch_games(selected_game)
		glitching = false
		selected_game = -1
	

###### CHEAT CODE INPUT ######
func handle_directional_input(dir : Direction, pressed : bool):
	if glitching or not zoom_out:
		current_sequence = []
		return
	if not pressed:
		return # I have this as a parameter just in case, I guess
	
	current_sequence.append(dir)
	if len(current_sequence) > 5:
		current_sequence.remove_at(0)
	
	# Check if input matches any of the available codes
	for code in available_codes:
		if current_sequence == code:
			if code_to_game(code) != Globals.current_game_index:
				print("Code successfully inputted!")
				#Globals.switch_games(code_to_game(code))
				selected_game = code_to_game(code)
				glitching = true
				current_sequence = []
				return
	

func code_to_game(code) -> Globals.GameList:
	if code == default_code:
		return Globals.GameList.DEFAULT
	if code == boom_code:
		return Globals.GameList.BOOM
	if code == gateway_code:
		return Globals.GameList.GATEWAY
	if code == critter_junction_code:
		return Globals.GameList.CRITTER_JUNCTION
	return Globals.GameList.DEFAULT


# Show games when needed
func show_game(game: String):
	match game:
		"boom":
			%boom_game.show()
			available_codes.append(boom_code)
		"gateway":
			print("show gateway")
		"cri_jun":
			print("show critter junction")
