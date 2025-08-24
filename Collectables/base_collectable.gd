extends Area2D

class_name BaseCollectable2D

const BASE_VALUE = 1

@export var money_value := 2
@export var health_value := 50

var pickup_sound = null

func get_value():
	return BASE_VALUE

func _ready():
	
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " object is not the child of in the SwitchWrapper"))
		
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: CharacterBody2D):
	if body is BasePlayer2D:
		var player = body as BasePlayer2D
		#player._on_get_collectable(self)
		player.collectables += money_value
		player.heal(health_value)
		if pickup_sound:
			pickup_sound.play()
		await get_tree().process_frame
		process_mode = Node.PROCESS_MODE_DISABLED
		$Sprite2D.visible = false
		if pickup_sound:
			await pickup_sound.finished
		get_parent().queue_free()
