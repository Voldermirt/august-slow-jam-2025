extends CharacterBody2D

class_name BaseEntity2D 

const BASE_MAX_HEALTH: float = 100
const DAMAGE_LAYER_NUMER: int = 32

var health: float

var damage_recovery_seconds: float
var recovery_timer: Timer

var moving_speed: float = 100.0

var cur_knock_force: Vector2
var cur_knock_duration: float


# Copied the data from another player instance, useful for switching games and maintaining data
func retrieve_data(retrieved_from: BaseEntity2D):
	self.health = retrieved_from.health

# Gives entity the data it should receive on initial Îspawning
func set_spawn_data():
	self.health = BASE_MAX_HEALTH


func knockback_applied(direction: Vector2, force: float, duration: float):
	cur_knock_force = direction * force
	cur_knock_duration = duration 

func _knockback_procses(delta):
	var direction = cur_knock_force.normalized()
	velocity = cur_knock_force
	cur_knock_duration -= delta
	if cur_knock_duration <= 0.0:
		cur_knock_force = Vector2.ZERO
	
func _ready():
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " entity is not the child of in the SwitchWrapper"))
	
	if (collision_layer & DAMAGE_LAYER_NUMER) == 0:
		collision_layer += DAMAGE_LAYER_NUMER
	
	recovery_timer = Timer.new()
	recovery_timer.one_shot = true
	recovery_timer.autostart = false
	recovery_timer.timeout.connect(_end_damage_recovery)
	add_child(recovery_timer)

func _physics_process(delta):
	pass

func _on_getting_hit(damage: float):
	health -= damage
	if health <= 0:
		_on_death()
	else:
		_start_damage_recovery()

func _on_death():
	var parent = get_parent()
	if parent != null and parent.is_in_group("switch_wrapper"):
		get_parent().queue_free()

# Start the recover after damage, during which player can't be damaged
func _start_damage_recovery():
	recovery_timer.start(damage_recovery_seconds)
	modulate.a = 0.5
	collision_layer -= DAMAGE_LAYER_NUMER

func _end_damage_recovery():
	collision_layer += DAMAGE_LAYER_NUMER
	modulate.a = 1
