extends Node
class_name MainRoom

enum Direction {UP, DOWN, LEFT, RIGHT}

@export var debug_mode = false

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
@onready var player = $ScreenEffects/EffectViewport/Render2D/Level2D/Level/PlayerWrapper2D/DefaultPlayer2D
@onready var ui = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI
@onready var cheat_intro = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI/ToolTips/CheatIntro
@onready var boom_intro = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI/ToolTips/BoomIntro
@onready var gateway_intro = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI/ToolTips/GatewayIntro
@onready var critter_intro = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI/ToolTips/CritterIntro
@onready var bsod = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI/BSoD
@onready var panel = $ScreenEffects/EffectViewport/Render2D/Level2D/CanvasLayer/UI/ToolTips/Panel
@onready var death_effect := $ScreenEffects/EffectViewport/Render2D/Level2D/DeathEffect
@onready var death_particles := $ScreenEffects/EffectViewport/Render2D/Level2D/DeathEffect/DeathParticles

# Game cases are unique identifiers already

var zoom_out = false      # Are we zoomed/zooming out
var current_sequence = [] # Current cheat code input sequence


# Shader variables
@export_group("Glitch effect")
@export var glitch_curve : Curve
@export var max_glitch := 600
@export var glitch_seconds := 1.0
var glitch_spin_ratio = 0.2
var glitch_rotation := 0.0
var current_glitch_time := 0.0
var glitching := false
var min_glitch := 0

var selected_game : Globals.GameList

func _ready() -> void:
	available_codes = [default_code]
	Globals.level_change_requested.connect(change_level)
	view_2d.material.set_shader_parameter("offset", 0.0)
	Globals.first_time_swapping_to.connect(show_tooltip)
	Globals.player_died.connect(play_death_effect)
	Globals.entered_glitch_area.connect(enter_glitch_area)
	

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
		Globals.set_zoom_out(true)
		get_tree().paused = true
		$ComputerAmbience.play()
		$RoomAmbience.play()
	elif event.is_action_released("zoom") and zoom_out:
		# Zoom in
		zoom_out = false
		zoom_anim.play_backwards("zoom")
		Globals.set_zoom_out(false)
	
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
		$ComputerAmbience.stop()
		$RoomAmbience.stop()

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
	
	[$KeyboardSound1, $KeyboardSound2].pick_random().play()
	
	
	current_sequence.append(dir)
	if len(current_sequence) > 5:
		current_sequence.remove_at(0)
	
	# Check if input matches any of the available codes
	if debug_mode:
		available_codes = [default_code, boom_code, gateway_code, critter_junction_code]
	var green = false
	for code in available_codes:
		if current_sequence == code:
			if code_to_game(code) != Globals.current_game_index:
				print("Code successfully inputted!")
				#Globals.switch_games(code_to_game(code))
				selected_game = code_to_game(code)
				$GameChangeSound.play()
				glitching = true
				current_sequence = []
				green = true
	
	var arrow_dirs = [dir]
	if green:
		arrow_dirs = [Direction.UP, Direction.DOWN, Direction.LEFT, Direction.RIGHT]
	for arrow_dir in arrow_dirs:
		pulse_arrow(arrow_dir, green)


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


# Unlock games when needed
# just realized I could have just used the globals.gamelist thing but oh well
func unlock_game(game: String):
	$UnlockSound.play()
	match game:
		"boom":
			panel.show()
			%boom_game.show()
			available_codes.append(boom_code)
			cheat_intro.show()
		"gateway":
			%gateway_game.show()
			available_codes.append(gateway_code)
		"cri_jun":
			%cri_jun_game.show()
			available_codes.append(critter_junction_code)
		_:
			push_error("Unlocked invalid game! Check if you are matching the cases correctly?")

# probably a much better way to do this but oh well... shows the tooltips
func show_tooltip(game: Globals.GameList):
	panel.show()
	match game:
		Globals.GameList.BOOM:
			cheat_intro.hide()
			boom_intro.show()
			await get_tree().create_timer(7).timeout
			boom_intro.hide()
		Globals.GameList.GATEWAY:
			gateway_intro.show()
			await get_tree().create_timer(7).timeout
			gateway_intro.hide()
		Globals.GameList.CRITTER_JUNCTION:
			critter_intro.show()
			await get_tree().create_timer(7).timeout
			critter_intro.hide()
	panel.hide()


# im tired
func _on_end_room_trip_wire_basically_body_entered(body: Node2D) -> void:
	player.death.connect(end_game)
	$ScreenEffects/EffectViewport/Render2D/Level2D/Level/PlayerWrapper2D.player_switched_games.connect(_on_player_wrapper_2d_player_switched_games)

func end_game():
	bsod.show()

func _on_player_wrapper_2d_player_switched_games(players_newest_scene: BasePlayer2D) -> void:
	if players_newest_scene.is_connected("death", end_game) == false:
		players_newest_scene.death.connect(end_game)


func _on_unlock_cri_jun_body_entered(body: Node2D) -> void:
	if body is BasePlayer2D and available_codes.has(critter_junction_code) == false:
		unlock_game("cri_jun")

func play_death_effect(location):
	death_effect.visible = true
	death_particles.global_position = location
	death_particles.emitting = true
	await get_tree().create_timer(3.1).timeout
	death_effect.visible = false

func pulse_arrow(dir: Direction, green : bool):
	var arrow : Sprite3D
	match dir:
		Direction.UP:
			arrow = %UpArrow
		Direction.RIGHT:
			arrow = %RightArrow
		Direction.DOWN:
			arrow = %DownArrow
		Direction.LEFT:
			arrow = %LeftArrow
	
	var default_color = Color(1, 1, 1, 0.25)
	var color = Color.GREEN if green else Color.WHITE
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(arrow, "modulate", color, 0.1)
	tween.tween_property(arrow, "modulate", default_color, 0.1)
	

func enter_glitch_area():
	min_glitch = 1.0
	glitch_spin_ratio = 0.1
