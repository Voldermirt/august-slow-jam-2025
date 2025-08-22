extends InteractionManager

signal on_interaction

func receive_interaction() -> void:
	emit_signal("on_interaction")
