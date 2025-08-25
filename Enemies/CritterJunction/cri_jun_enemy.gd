extends BaseEntity2D

class_name CriJunVillager2D

signal fulfilled_request
# this isn't an enemy but an NPC

@onready var icon: AtlasTexture = preload("res://resources/cri_jun_atlas_icons.tres")

# These are filled out by the EnemyWrapper
# Apple by default
var requested_fruit: int = 0
var requested_count: int = 0
var fulfilled: int = false

func _ready():
	super._ready()
	$Sprite2D.frame = randi_range(0, $Sprite2D.hframes - 1)
	
	if fulfilled:
		$Control.hide()
	else:
		# offset the atlas to be the correct fruit
		var unique_icon = icon.duplicate(true)
		unique_icon.set_region(Rect2(16 * requested_fruit, 0, 16, 16))
		%ItemIcon.texture = unique_icon
		%ItemCount.text = str(requested_count)

func _physics_process(delta: float) -> void:
	pass


func _on_interaction_manger_on_interaction() -> void:
	if fulfilled:
		return
	
	if PlayerStats.fruit_count[requested_fruit] >= requested_count:
		%ItemCount.text = str(requested_count)
		$Control.hide()
		emit_signal("fulfilled_request")
		fulfilled = true
		PlayerStats.fruit_count[requested_fruit] -= requested_count
		[$FulfillmentNoise1, $FulfillmentNoise2].pick_random().play()
	else:
		%ItemCount.text = str("[shake]" + str(requested_count) + "[/shake]")
		$ShakeTimer.start()


func _on_shake_timer_timeout() -> void:
	%ItemCount.text = str(requested_count)
