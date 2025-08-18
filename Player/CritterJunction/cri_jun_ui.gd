extends GeneralUI

@onready var apple_icon = $ScrollContainer/SeedsContainer/AppleIcon
@onready var buttons = $ScrollContainer/SeedsContainer.get_children()
@onready var seed_count = $ScrollContainer/SeedsContainer.get_child_count()

var index = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		if index == seed_count - 1:
			index = 0
		else:
			index += 1
	elif event.is_action_pressed("ui_down"):
		if index == 0:
			index = seed_count - 1
		else:
			index -= 1
	buttons[index].grab_focus()
