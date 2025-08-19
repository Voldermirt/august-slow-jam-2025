extends BaseEntity2D

class_name BaseEnemy2D

const DEFAULT_RECOVERY_SECONDS: float = 0.2
const ENEMY_MOVEMENT: float = 90
const ENEMY_BASE_HEALTH: float = 20
const ENEMY_BASE_CONTACT_DAMAGE: float = 5

@onready var on_contact_hitbox: Area2D = $Area2D
@onready var n_agent: NavigationAgent2D

var on_contact_hit_delay_timer: Timer 
var stationary_timer: Timer

var player_body: BasePlayer2D
var anim : AnimatedSprite2D = null

# Gives entity the data it should receive on initial spawning
func set_spawn_data():
	super.set_spawn_data()
	self.health = BASE_MAX_HEALTH

# Moves towards the navigation agent's target
func move_to_ntarget():
	var position: Vector2 = n_agent.get_next_path_position()
	var from: Vector2 = self.global_position
	var direction = to_local(position).normalized()
	self.velocity = direction * moving_speed
	move_and_slide()
	
func make_path(position: Vector2):
	if n_agent == null:
		return Vector2.INF
	n_agent.target_position = position
	return n_agent.target_position

func make_player_path():
	if player_body == null:
		return Vector2.INF
	return make_path(player_body.global_position)
	
func make_player_around_path():
	if player_body == null:
		return false
	
	var player_pos: Vector2 = player_body.global_position
	var player_dir: Vector2 = global_position.direction_to(player_pos)

	# Get perpendicular direction
	var perpendicular: Vector2 = Vector2(-player_dir.y, player_dir.x)

	# Randomize clockwise / counterclockwise
	if randi() % 2 == 1:
		perpendicular = -perpendicular

	var around_player_radius: float = 100
	var final_destination_position: Vector2 = player_pos + perpendicular * around_player_radius
	
	#if final_destination_position.distance_squared_to(n_agent.target_position) < 20:
		#perpendicular = -perpendicular
		#final_destination_position = player_pos + perpendicular * around_player_radius

	make_path(final_destination_position)
	return true


func _ready():
	super._ready()
	await get_tree().process_frame
	
	# Assign the player to navigate towards
	player_body = get_tree().get_first_node_in_group("player") as BasePlayer2D
	
	moving_speed = ENEMY_MOVEMENT
	
	
	#if (collision_layer & ENEMY_LAYER_NUMER) == 0:
		#collision_layer += ENEMY_LAYER_NUMER
	#if (collision_mask & PLAYER_LAYER_NUMBER) == 0:
		#collision_mask += PLAYER_LAYER_NUMBER
		
	if n_agent == null:
		n_agent = NavigationAgent2D.new()
		n_agent.navigation_finished.connect(_n_navigation_reached)
		n_agent.link_reached.connect(_n_link_reached)
		
		if OS.is_debug_build():
			n_agent.debug_enabled = true
		
		add_child(n_agent)
	else: 
		push_error(str(self," does not have an NavigationAgent2D pathfinding tool! It won't be able to move!"))
	
	if on_contact_hitbox != null:
		on_contact_hitbox.body_entered.connect(_on_hitbox_entering)
		
		on_contact_hit_delay_timer = Timer.new()
		on_contact_hit_delay_timer.one_shot = true
		on_contact_hit_delay_timer.autostart = false
		on_contact_hit_delay_timer.timeout.connect(_on_contact_hitbox_timeout)
		add_child(on_contact_hit_delay_timer)
	else: 
		push_error(str(self," does not have an Area2D hitbox! It won't be able to hit the player on contact!"))
		
	stationary_timer = Timer.new()
	stationary_timer.one_shot = true
	stationary_timer.autostart = false
	stationary_timer.timeout.connect(_on_stationary_timeout)
	add_child(stationary_timer)
	

func _process(delta):
	if n_agent != null and OS.is_debug_build():
		if Input.is_key_pressed(KEY_E):
			make_player_path()
		if Input.is_key_pressed(KEY_R):
			make_player_around_path()
	
func _physics_process(delta):
	if cur_knock_duration > 0.0:
		_knockback_proccess(delta)
	else:
		if n_agent != null and n_agent.target_position != Vector2.INF and stationary_timer.time_left <= 0:
			move_to_ntarget()
	animate()

func animate():
	if not anim:
		return
	
	if velocity.length() > 0:
		anim.play("walk")
	else:
		anim.play("idle")
	
	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true

func _n_navigation_reached():
	var chance_rolled: int = randi_range(0, 100)
	if chance_rolled > 90:
		stationary_timer.start(randi_range(0.5, 0.8))
	elif chance_rolled > 70:
		make_player_around_path()
	else:
		make_player_path()
	
func _n_link_reached():
	pass

func _on_hitbox_entering(body: Node2D):
	if body is BasePlayer2D:
		var delay = randi_range(0.3, 0.6)
		on_contact_hit_delay_timer.start(delay)
		stationary_timer.start(delay)
		
func _on_contact_hitbox_timeout():
	var bodies: Array[Node2D] = on_contact_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body is BasePlayer2D:
			(body as BasePlayer2D)._on_getting_hit(ENEMY_BASE_CONTACT_DAMAGE)
			var dir = global_position.direction_to(body.global_position)
			global_position += dir * (global_position.distance_to(body.global_position)/2)
			stationary_timer.start(0.5)
			

func _on_stationary_timeout():
	_n_navigation_reached()
