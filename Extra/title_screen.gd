extends Control


var main_scene := preload("res://Map/main_room.tscn")

func _ready() -> void:
	Globals.set_music(false)
	Globals.can_switch = false

func _on_play() -> void:
	$UISound.play()
	Globals.set_music(true)
	Globals.can_switch = true
	#Globals.change_level(main_scene)
	get_tree().change_scene_to_packed(main_scene)

func _on_quit() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if $Music.get_playback_position() < 20:
			$Music.seek(20)
		if $IntroSequence.visible:
			$UISound.play()
		$IntroSequence.visible = false
		$IntroSequence/AnimationPlayer.stop()
