extends StaticBody2D


@export var default_texture : Texture2D
@export var boom_texture : Texture2D
@export var gateway_texture : Texture2D
@export var cri_jun_texture : Texture2D

#func _ready() -> void:
	#if get_parent().is_in_group("room"):
		#get_parent().all_enemies_died.connect(_on_all_enemies_dead)
	#else:
		#_on_all_enemies_dead()

func open(arg = null):
	# Play a sound
	#queue_free()
	process_mode = Node.PROCESS_MODE_DISABLED
	$Sprite2D.visible = false

func close(arg = null):
	# Play a sound
	process_mode = Node.PROCESS_MODE_INHERIT
	$Sprite2D.visible = true

func switch_to(game : Globals.GameList):
	match game:
		Globals.GameList.DEFAULT:
			$Sprite2D.texture = default_texture
		Globals.GameList.BOOM:
			$Sprite2D.texture = boom_texture
		Globals.GameList.GATEWAY:
			$Sprite2D.texture = gateway_texture
		Globals.GameList.CRITTER_JUNCTION:
			$Sprite2D.texture = cri_jun_texture
		_:
			push_error("Trying to switch to a non-existing game!")
