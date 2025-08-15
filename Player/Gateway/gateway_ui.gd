extends GeneralUI

class_name Gateway2D

@onready var orange_indicator := $PortalIndicatorBG/OrangeIndicator
@onready var blue_indicator := $PortalIndicatorBG/BlueIndicator

#func _ready() -> void:
	#update_ui()
	#Globals.ui_update_requested.connect(update_ui)

func update_ui():
	var blue = Globals.get_portal(false) != null
	var orange = Globals.get_portal(true) != null
	
	var blue_scale = Vector2.ONE if blue else Vector2.ZERO
	var orange_scale = Vector2.ONE if orange else Vector2.ZERO
	var blue_tween = create_tween().set_ease(Tween.EASE_OUT)
	blue_tween.tween_property(blue_indicator, "scale", blue_scale, 0.3)
	var orange_tween = create_tween().set_ease(Tween.EASE_OUT)
	orange_tween.tween_property(orange_indicator, "scale", orange_scale, 0.3)
	#$BlueBG/BlueIndicator.visible = blue
	#$OrangeBG/OrangeIndicator.visible = orange

func _process(delta: float) -> void:
	# Spin animation
	blue_indicator.rotation_degrees += 90 * delta
	if blue_indicator.rotation_degrees >= 360:
		blue_indicator.rotation_degrees -= 360
	
	orange_indicator.rotation_degrees += 90 * delta
	if orange_indicator.rotation_degrees >= 360:
		orange_indicator.rotation_degrees -= 360