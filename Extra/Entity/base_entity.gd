extends CharacterBody2D

class_name BaseEntity2D 

signal death

const BASE_MAX_HEALTH: float = 100
const ENEMY_LAYER_NUMER: int = 2
const PLAYER_LAYER_NUMBER: int = 1

var allowed_to_move: bool = true

var health: float
var is_invincible: bool = false

var damage_recovery_seconds: float
var recovery_timer: Timer

var moving_speed: float = 100.0

var cur_knock_force: Vector2
var cur_knock_duration: float

var hurt_sound = null
var death_sound = null
var anim : AnimatedSprite2D = null

func get_recovery_time():
	return damage_recovery_seconds

func get_max_health():
	return BASE_MAX_HEALTH

# Copied the data from another player instance, useful for switching games and maintaining data
func retrieve_data(retrieved_from: BaseEntity2D):
	self.health = (retrieved_from.health / retrieved_from.get_max_health())*get_max_health()

# Gives entity the data it should receive on initial Îspawning
func set_spawn_data():
	self.health = get_max_health()

func save_json_data() -> Dictionary:
	var base_player_json_data = {
		"health": health,
		"global_position": global_position
	}
	return base_player_json_data

func load_json_data(data: Dictionary):
	
	health = data["health"]
	global_position = str_to_var("Vector2" + data["global_position"])
	
func knockback_applied(direction: Vector2, force: float, duration: float):
	cur_knock_force = direction * force
	cur_knock_duration = duration 

func _knockback_proccess(delta):
	var direction = cur_knock_force.normalized()
	velocity = cur_knock_force
	cur_knock_duration -= delta
	if cur_knock_duration <= 0.0:
		cur_knock_force = Vector2.ZERO
	

func _ready():
	if not get_parent().is_in_group("switch_wrapper"):
		assert(false, str(self, " entity is not the child of in the SwitchWrapper"))
	
	if not is_in_group("entity"):
		add_to_group("entity", true)
	
	recovery_timer = Timer.new()
	recovery_timer.one_shot = true
	recovery_timer.autostart = false
	recovery_timer.timeout.connect(_end_damage_recovery)
	add_child(recovery_timer)

func _physics_process(delta):
	if health <= 0:
		return
	pass

func _on_getting_hit(damage: float, bypass_invincibility=false, hit_by=""):
	if (bypass_invincibility or (not is_invincible)) and health > 0:
		health -= damage
		if health <= 0:
			_on_death()
		else:
			if hurt_sound:
				hurt_sound.play()
			_start_damage_recovery()

func heal(amount : float):
	health = clamp(health + amount, 0, BASE_MAX_HEALTH)

func _on_death():
	if death_sound:
		death_sound.play()
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
	death.emit()


# Start the recover after damage, during which player can't be damaged
func _start_damage_recovery():
	recovery_timer.start(get_recovery_time())
	modulate.a = 0.5
	is_invincible = true

func _end_damage_recovery():
	is_invincible = false
	modulate.a = 1
