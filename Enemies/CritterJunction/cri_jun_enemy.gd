extends BaseEnemy2D

class_name CriJunEnemy2D

signal fulfilled_request
# this isn't an enemy but an NPC

func _ready():
	super._ready()
	
	# Assign the player to navigate towards
	await get_tree().process_frame
	player_body = get_tree().get_first_node_in_group("player") as BasePlayer2D

func _physics_process(delta: float) -> void:
	pass
