extends Area2D

class_name BaseCollectable2D

const BASE_VALUE = 1

@export var money_value := 2
@export var health_value := 50

var pickup_sound = null

func get_value():
	return BASE_VALUE

func save_json_data() -> Dictionary:
	var base_player_json_data = {
		"global_position": global_position
	}
	return base_player_json_data

func load_json_data(data: Dictionary):
	global_position = str_to_var("Vector2" + data["global_position"])

func _ready():
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " object is not the child of in the SwitchWrapper"))
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: CharacterBody2D):
	if body is BasePlayer2D:
		var player = body as BasePlayer2D
		#player._on_get_collectable(self)
		player.collectables += money_value
		PlayerStats._money = player.collectables
		PlayerStats.player_collectibles += 1
		player.heal(health_value)
		if pickup_sound:
			pickup_sound.play()
		await get_tree().process_frame
		process_mode = Node.PROCESS_MODE_DISABLED
		$Sprite2D.visible = false
		
		set_deferred("monitoring", false)
		hide()
		
		#$Sprite2D.visible = false
		#get_parent().queue_free()
