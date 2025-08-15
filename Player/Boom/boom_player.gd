extends BasePlayer2D

class_name BoomPlayer2D

const BOOM_PLAYER_MAX_HEALTH: float = 100

@onready var weapon := $BoomGun

func get_max_health():
	return BOOM_PLAYER_MAX_HEALTH

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	_weapon_rotation_process(weapon)

func retrieve_data(retrieved_from: BaseEntity2D):
	super.retrieve_data(retrieved_from)
