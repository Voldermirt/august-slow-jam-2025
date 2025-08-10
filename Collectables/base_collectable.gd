extends Area2D

class_name BaseCollectable2D

func _ready():
	
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " object is not the child of in the SwitchWrapper"))
		
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("player"):
		get_parent().queue_free()
