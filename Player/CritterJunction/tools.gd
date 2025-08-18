extends BaseWeapon2D

@onready var interaction = $Polygon2D/Interaction

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		interaction.initiate_interaction()
