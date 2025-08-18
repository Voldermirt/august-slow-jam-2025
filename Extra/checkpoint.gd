extends Area2D

class_name Checkpoint

var current_checkpoint_data = {}

const SAVE_PATH = "user://saved_game_state.tscn"

func _process(delta):
	if OS.is_debug_build() and Input.is_action_pressed("interact"):
		load_saved_scene()
	
func save_current_scene():
	var packed_scene = PackedScene.new()
	var current_scene = get_tree().get_current_scene()
	packed_scene.pack(current_scene)
	ResourceSaver.save(packed_scene, SAVE_PATH)
	
	#var current_scene = get_tree().get_current_scene()
	#var packed_scene = PackedScene.new()
	#packed_scene.pack(current_scene)
	#ResourceSaver.save(packed_scene, SAVE_PATH)
	#print("Current scene saved to user://saved_game_state.tscn")

func load_saved_scene():
	# Load the PackedScene resource from the file
	var packed_scene = ResourceLoader.load(SAVE_PATH)

	get_tree().call_deferred("change_scene_to_packed", packed_scene)
	
	#get_tree().change_scene_to_packed(load(SAVE_PATH))
	#await get_tree().process_frame


func _on_body_entered(body: Node):
	if body is BasePlayer2D:
		save_current_scene()
