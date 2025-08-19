extends BaseEntity2D

class_name BaseEnemy2D

# If enemy is "neutral", it would just walk and look around 
# If enemy is "targeting", it will move around the player and attack
enum ThinkState {Neutral, Targeting}

const WANDER_DISTANCE_MAX: float = 500
const WANDER_DISTANCE_MIN: float = 5

const DEFAULT_RECOVERY_SECONDS: float = 0.2
const ENEMY_MOVEMENT: float = 90
const ENEMY_BASE_HEALTH: float = 20
const ENEMY_BASE_CONTACT_DAMAGE: float = 5

# Time it takes to make a decision
const DECISION_TIME_DEFAULT: float = 1

const PLAYER_DETECTED_DELAY_MAX: float = 0.8
const PLAYER_DETECTED_DELAY_MIN: float = 0.3

var nav_region: NavigationRegion2D
@onready var on_contact_hitbox: Area2D = $Area2D
@onready var awareness_raycast: RayCast2D = $RayCast2D
@onready var n_agent: NavigationAgent2D

var thinking_state: ThinkState

# How long will the enemy wait before attacking again
var on_contact_hit_delay_timer: Timer 
#var stationary_timer: Timer
# How long it is allowed for an enemy to travel in one path
var pathing_limit_timer: Timer
var decision_timer: Timer
var thinking_switch_timer: Timer
var spawn_delay: Timer

var player_body: BasePlayer2D
var anim : AnimatedSprite2D = null

var hitbox_og_mask: int

# Gives entity the data it should receive on initial spawning
func set_spawn_data():
	super.set_spawn_data()
	self.health = BASE_MAX_HEALTH
	thinking_state = ThinkState.Neutral

# Moves towards the navigation agent's target
func move_to_ntarget():
	var position: Vector2 = n_agent.get_next_path_position()
	var from: Vector2 = self.global_position
	var direction = to_local(position).normalized()
	self.velocity = direction * moving_speed
	move_and_slide()
	
func make_path(position: Vector2):
	if n_agent == null or position == Vector2.ZERO or position == Vector2.INF:
		return Vector2.INF
	n_agent.target_position = position
	awareness_raycast.look_at(position)
	return n_agent.target_position

func make_wander_path():
	if nav_region == null:
		return make_path(Vector2.INF)
	
	var random_move_position: Vector2 = NavigationServer2D.region_get_random_point(nav_region, 1, false)
	var distance = self.global_position.distance_to(random_move_position)
	
	# We received out-of-range random point
	if distance > WANDER_DISTANCE_MAX and distance < WANDER_DISTANCE_MIN:
		return make_path(Vector2.INF)
	return make_path(random_move_position)

func make_player_path():
	if player_body == null:
		return make_path(Vector2.INF)
	return make_path(player_body.global_position)
	
func make_player_around_path():
	if player_body == null:
		make_path(Vector2.INF)
	
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

	return make_path(final_destination_position)
	


func _ready():
	super._ready()
	
	# Assign the player to navigate towards
	player_body = get_tree().get_first_node_in_group("player") as BasePlayer2D
	
	moving_speed = ENEMY_MOVEMENT
	
	if n_agent == null:
		n_agent = NavigationAgent2D.new()
		n_agent.navigation_finished.connect(_n_navigation_reached)
		n_agent.link_reached.connect(_n_link_reached)
		
		if OS.is_debug_build():
			n_agent.debug_enabled = true
		
		nav_region = get_tree().get_first_node_in_group("navigation_map")
		
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
		
	hitbox_og_mask = collision_mask
	
	pathing_limit_timer = Timer.new()
	pathing_limit_timer.one_shot = true
	pathing_limit_timer.autostart = false
	pathing_limit_timer.timeout.connect(_on_pathing_limit_timeout)
	
	decision_timer = Timer.new()
	decision_timer.one_shot = true
	decision_timer.autostart = false
	decision_timer.timeout.connect(_on_decision_timeout)
	
	thinking_switch_timer = Timer.new()
	thinking_switch_timer.one_shot = true
	thinking_switch_timer.autostart = false
	thinking_switch_timer.timeout.connect(_on_thinking_timeout)
	
	spawn_delay = Timer.new()
	spawn_delay.one_shot = true
	spawn_delay.autostart = true
	#add_child(stationary_timer)
	
	add_child(decision_timer)
	add_child(thinking_switch_timer)
	add_child(spawn_delay)
	add_child(pathing_limit_timer)
	
	decision_timer.start()
	
func is_player_found():
	if awareness_raycast != null and player_body != null:
		return awareness_raycast.is_colliding() and awareness_raycast.get_collider() is BasePlayer2D and thinking_state == ThinkState.Neutral and thinking_switch_timer.time_left <= 0
	return false

# Decision-making
func _process(delta):
	if n_agent != null and spawn_delay.time_left <= 0:
		match thinking_state:
			ThinkState.Neutral:
					pass
			ThinkState.Targeting:
				pass

# Movement
func _physics_process(delta):
	if n_agent != null and spawn_delay.time_left <= 0:
		match thinking_state:
			ThinkState.Neutral:
				awareness_raycast.look_at(player_body.global_position)
				# Check if we could find the player
				if is_player_found():
					thinking_switch_timer.start(randi_range(PLAYER_DETECTED_DELAY_MIN, PLAYER_DETECTED_DELAY_MAX))
				
			ThinkState.Targeting:
				pass
				
		if cur_knock_duration > 0.0:
			_knockback_proccess(delta)
		elif n_agent.target_position != Vector2.INF and decision_timer.time_left <= 0:
			move_to_ntarget()
		# We have an invalid desitination position, try to find another
		elif n_agent.target_position == Vector2.INF:
			decide_movement()
			
	animate()


func decide_movement():
	var desired_movement_position: Vector2 = Vector2.INF
	
	pathing_limit_timer.stop()
	
	match thinking_state:
		ThinkState.Neutral:
			## If we have not yet found the player
			if thinking_switch_timer.time_left <= 0:
				desired_movement_position = make_wander_path()
		ThinkState.Targeting:
			var chance_rolled: int = randi_range(0, 100)
			if chance_rolled > 90:
				decision_timer.start(DECISION_TIME_DEFAULT)
			elif chance_rolled > 70:
				desired_movement_position = make_player_around_path()
			else:
				desired_movement_position = make_player_path()
	
	if desired_movement_position != Vector2.INF:
		var time: float = 0.1
		var speed: float = moving_speed
		var distance: float = global_position.distance_to(desired_movement_position)
		
		if speed != 0:
			time = (distance/speed)
			if thinking_state == ThinkState.Targeting:
				time /=2
		pathing_limit_timer.start(time)
	return desired_movement_position
	
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

func _on_hitbox_entering(body: Node2D):
	if body is BasePlayer2D:
		var delay = randi_range(0.3, 0.6)
		on_contact_hit_delay_timer.start(delay)
		collision_mask = hitbox_og_mask
		
func _on_contact_hitbox_timeout():
	var bodies: Array[Node2D] = on_contact_hitbox.get_overlapping_bodies()
	collision_mask = 0
	for body in bodies:
		if body is BasePlayer2D:
			(body as BasePlayer2D)._on_getting_hit(ENEMY_BASE_CONTACT_DAMAGE)
			var dir = global_position.direction_to(body.global_position)
			global_position += dir * (global_position.distance_to(body.global_position)/2)
			decision_timer.start(DECISION_TIME_DEFAULT)

func _n_navigation_reached():
	match thinking_state:
		ThinkState.Neutral:
			decision_timer.start(DECISION_TIME_DEFAULT)
		ThinkState.Targeting:
			decision_timer.start(0.1)
	
func _n_link_reached():
	pass

func _on_decision_timeout():
	decide_movement()

func _on_pathing_limit_timeout():
	decide_movement()

# Switch the states
func _on_thinking_timeout():
	match thinking_state:
		ThinkState.Neutral:
			thinking_state = ThinkState.Targeting
		ThinkState.Targeting:
			thinking_state = ThinkState.Neutral
		_: 
			thinking_state = ThinkState.Neutral
	decide_movement()
