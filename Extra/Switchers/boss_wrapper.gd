extends SwitchWrapper2D

class_name BossWrapper2D

@export var bound_area: Area2D

func _ready():
	super._ready()
	if switching_scene != null and switching_scene is BaseBoss2D:
		(switching_scene as BaseBoss2D).bound_area = bound_area
		(switching_scene as BaseBoss2D).connect_bound_area()
	
func switch_to(game: Globals.GameList):
	super.switch_to(game)
	if switching_scene != null and switching_scene is BaseBoss2D:
		(switching_scene as BaseBoss2D).bound_area = bound_area
		(switching_scene as BaseBoss2D).connect_bound_area()

func _on_child_entered_tree(node: Node):
	super._on_child_entered_tree(node)
