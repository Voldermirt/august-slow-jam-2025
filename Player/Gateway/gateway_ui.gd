extends Control


func _ready() -> void:
	update_ui()
	Globals.ui_update_requested.connect(update_ui)

func update_ui():
	var blue = Globals.get_portal(false) != null
	var orange = Globals.get_portal(true) != null
	
	$BlueBG/BlueIndicator.visible = blue
	$OrangeBG/OrangeIndicator.visible = orange
