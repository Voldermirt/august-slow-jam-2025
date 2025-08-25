extends BaseObject2D

class_name CriJunObject2D

# Get fruit from the Critter Junction UI
signal fetch_fruit()

@onready var collectible_wrapper = preload("res://Extra/Switchers/collectable_wrapper.tscn")
@onready var fruit_collectible = preload("res://Collectables/CritterJunction/cri_jun_collectable.tscn")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var left = $FruitSpawns/LeftPoint
@onready var middle = $FruitSpawns/MiddlePoint
@onready var right = $FruitSpawns/RightPoint

# plant
enum state {PLOT, SAPLING, TREE}
enum fruit {APPLE, ORANGE, CHERRY, PEACH, PEAR}

@export var current_state: state
var fruit_type: fruit

var made_fruit = false

func _ready():
	super._ready()
	await get_tree().process_frame
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
			if made_fruit == false:
				# Instance new fruits into an array
				var new_fruits = [fruit_collectible.instantiate(), fruit_collectible.instantiate(), fruit_collectible.instantiate()]
				
				# Store the positions for each
				var positions = [left.global_position, middle.global_position, right.global_position]
				
				for i in range(0, 3):
					# Change the icon and position for each fruit
					new_fruits[i].get_child(1).frame = fruit_type
					new_fruits[i].global_position = positions[i]
					new_fruits[i].add_to_group("spawned_fruits")
					
					# Delete the default crate as a child
					var collectible_instance = collectible_wrapper.instantiate()
					collectible_instance.get_child(0).queue_free()
					await get_tree().process_frame
					
					# add the fruit as a child instead
					collectible_instance.add_child(new_fruits[i])
					add_child(collectible_instance)
				made_fruit = true
			
			sprite.frame = 2
			collision.disabled = false

func _on_ui_get_index(index: int) -> void:
	fruit_type = index
	get_tree().get_first_node_in_group("cri_jun_ui").disconnect("get_fruit_index", _on_ui_get_index)

# Recieve interaction from Villager
func _on_plant_interaction() -> void:
	match current_state:
		state.PLOT:
			# Get what kind of fruit the player wants to plant
			get_tree().get_first_node_in_group("cri_jun_ui").get_fruit_index.connect(_on_ui_get_index)
			emit_signal("fetch_fruit")
			current_state = state.SAPLING
			sprite.frame = 1
			collision.disabled = true
			$PlantSound.play()
		# turn it back into a hole
		state.TREE:
			current_state = state.PLOT
			made_fruit = false
			for fruit in get_tree().get_nodes_in_group("spawned_fruits"):
				fruit.position.y = 6
			sprite.frame = 0
			collision.disabled = false
			$DigSound.play()
