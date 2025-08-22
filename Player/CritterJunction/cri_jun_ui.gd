extends BaseUI

signal get_fruit_index(index: int)

@onready var buttons = $PanelContainer/MarginContainer/ScrollContainer/SeedsContainer.get_children()
@onready var seed_count = $PanelContainer/MarginContainer/ScrollContainer/SeedsContainer.get_child_count()
@onready var fruit_counters = [%AppleCount, %OrangeCount, %CherryCount, %PeachCount, %PearCount]

var index = 0

func _ready() -> void:
	await get_tree().process_frame
	
	for plant in get_tree().get_nodes_in_group("plants"):
		plant.fetch_fruit.connect(_on_fetch_fruit)

func update_fruit(i: int):
	fruit_counters[i].text = str(PlayerStats.fruit_count[i])
	

# Scroll up and down to change which fruit is selected
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		if index == seed_count - 1:
			index = 0
		else:
			index += 1
	elif event.is_action_pressed("ui_up"):
		if index == 0:
			index = seed_count - 1
		else:
			index -= 1
	buttons[index].grab_focus()

func _on_fetch_fruit():
	emit_signal("get_fruit_index", index)

func update_ui():
	for i in range(0, 5):
		update_fruit(i)
