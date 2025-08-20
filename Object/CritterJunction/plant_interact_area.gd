extends InteractionManager

signal on_plant_interaction

func _ready() -> void:
	await get_tree().process_frame
	
# When Villager Interacts with the tree
func receive_interaction() -> void:
	emit_signal("on_plant_interaction")
