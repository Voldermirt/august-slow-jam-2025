extends BaseObject2D

class_name CriJunObject2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# plant
enum state {PLOT, SAPLING, TREE}
enum fruit {APPLE, ORANGE, CHERRY, PEACH, PEAR}

@export var current_state: state
@export var fruit_type: fruit

var made_fruit = false

func _ready():
	super._ready()


func _process(delta: float) -> void:
	match current_state:
		# plot can't be stepped on
		state.PLOT:
			sprite.frame = 0
			collision.disabled = false
		
		# sapling can be walked through
		state.SAPLING:
			sprite.frame = 1
			collision.disabled = true
		
		# tree can't be walked through
		state.TREE:
			sprite.frame = 2
			collision.disabled = false
