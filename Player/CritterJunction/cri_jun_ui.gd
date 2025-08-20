extends GeneralUI

signal get_fruit_index(index: int)

@onready var buttons = $ScrollContainer/SeedsContainer.get_children()
@onready var seed_count = $ScrollContainer/SeedsContainer.get_child_count()

var index = 0

func _ready() -> void:
	await get_tree().process_frame
	
	for plant in get_tree().get_nodes_in_group("plants"):
		plant.fetch_fruit.connect(_on_fetch_fruit)

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
