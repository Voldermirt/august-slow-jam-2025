extends BaseEntity2D

class_name BaseEnemy2D

# If enemy is "neutral", it would just walk and look around 
# If enemy is "targeting", it will move around the player and attack
enum ThinkState {Neutral, Targeting}

#const AWARENESS_TARGET_DISTANCE: float = 10
const AWARENESS_NEUTRAL_DISTANCE: float = 300
const AWARENESS_COLLISION_MASK: int = 9

const WANDER_DISTANCE_MAX: float = 100
const WANDER_DISTANCE_MIN: float = 5

const DEFAULT_RECOVERY_SECONDS: float = 0.2
const ENEMY_MOVEMENT: float = 90
const ENEMY_BASE_HEALTH: float = 20
const ENEMY_BASE_CONTACT_DAMAGE: float = 5
const KNOCKBACK_FORCE: float = 200

# Time it takes to make a decision
const DECISION_TIME_DEFAULT: float = 1

const ATTACK_DELAY_MAX: float = 0.3
const ATTACK_DELAY_MIN: float = 0.1

const PLAYER_DETECTED_DELAY_MAX: float = 1.5
const PLAYER_DETECTED_DELAY_MIN: float = 0.5

@onready var on_contact_hitbox: Area2D = $Area2D
@onready var n_agent: NavigationAgent2D

var nav_region: NavigationRegion2D
var awareness_raycast: RayCast2D
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

var hitbox_og_mask: int

func get_contact_damage() -> int:
	return ENEMY_BASE_CONTACT_DAMAGE

func get_attack_time() -> float: 
	return randf_range(ATTACK_DELAY_MIN, ATTACK_DELAY_MAX)

func get_max_health():
	return BASE_MAX_HEALTH
	
# Gives entity the data it should receive on initial spawning
func set_spawn_data():
	super.set_spawn_data()
	thinking_state = ThinkState.Neutral
	
func save_json_data() -> Dictionary:
	var data = super.save_json_data()
	#health = get_max_health()
	#data["think_state"] = thinking_state
	data["player_body"] = player_body
	
	return data

func load_json_data(data: Dictionary):
	super.load_json_data(data)
	#if data.get("think_state") != null:
		#thinking_state = data.get("think_state")
	thinking_state = ThinkState.Neutral
	
	spawn_delay.start(3)
	decision_timer.start(randi_range(2, 5)) # On checkpoint loading, disable an enemy for a bit
	pass


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
	if awareness_raycast != null:
		awareness_raycast.look_at(position)
	return n_agent.target_position

func make_wander_path():
	#if nav_region == null:
		#return make_path(Vector2.INF)
	#var random_move_position: Vector2 = global_position + global_position.direction_to(NavigationServer2D.region_get_random_point(nav_region, 1, false)).normalized()*WANDER_DISTANCE_MAX
	#var distance = self.global_position.distance_to(random_move_position)
	#return make_path(random_move_position)
	
	return Vector2.INF

func make_player_path():
	if player_body == null or not is_instance_valid(player_body):
		return make_path(Vector2.INF)
	return make_path(player_body.global_position)
	
func make_player_around_path():
	if player_body == null or not is_instance_valid(player_body):
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

func refresh_player_reference():
	player_body = get_tree().get_first_node_in_group("player") as BasePlayer2D

func _ready():
	super._ready()
	#await get_tree().process_frame
	
	# Assign the player to navigate towards
	#await get_tree().process_frame
	refresh_player_reference()
	
	thinking_state = ThinkState.Neutral
	
	moving_speed = ENEMY_MOVEMENT
	
	if n_agent == null:
		n_agent = NavigationAgent2D.new()
		n_agent.navigation_finished.connect(_n_navigation_reached)
		#n_agent.avoidance_enabled = true
		#n_agent.avoidance_mask = 1
		#n_agent.avoidance_layers = 1
		
		#if OS.is_debug_build():
			#n_agent.debug_enabled = true
		
		nav_region = get_tree().get_first_node_in_group("navigation_map")
		
		add_child(n_agent)
	else: 
		push_error(str(self," does not have an NavigationAgent2D pathfinding tool! It won't be able to move!"))
	
	if on_contact_hitbox != null:
		on_contact_hitbox.body_entered.connect(_on_hitbox_entering)
		on_contact_hit_delay_timer = Timer.new()
		on_contact_hit_delay_timer.set_wait_time(0.1)
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
	spawn_delay.wait_time = 3
	spawn_delay.autostart = true
	spawn_delay.timeout.connect(debug)
	#add_child(stationary_timer)
	
	awareness_raycast = RayCast2D.new()
	awareness_raycast.target_position = Vector2(AWARENESS_NEUTRAL_DISTANCE, 0)
	awareness_raycast.collision_mask = AWARENESS_COLLISION_MASK
	
	add_child(decision_timer)
	add_child(thinking_switch_timer)
	add_child(spawn_delay)
	add_child(pathing_limit_timer)
	add_child(awareness_raycast)
	
	#await get_tree().process_frame
	
	awareness_raycast.global_position = global_position
	decision_timer.start()
	
func is_player_seen() -> bool:
	if awareness_raycast != null and player_body != null and is_instance_valid(player_body):
		var stuff = [awareness_raycast.is_colliding(), awareness_raycast.get_collider()]
		return awareness_raycast.is_colliding() and awareness_raycast.get_collider() is BasePlayer2D and thinking_switch_timer.time_left <= 0
	return false
#
## Decision-making
func _process(delta):
	if not is_instance_valid(player_body):
		refresh_player_reference()
	#if n_agent != null and spawn_delay.time_left <= 0:
		#match thinking_state:
			#ThinkState.Neutral:
					#pass
			#ThinkState.Targeting:
				#pass

func _physics_process(delta):
	if health <= 0:
		return
	
	if cur_knock_duration > 0.0:
		_knockback_proccess(delta)
		
		move_and_slide()
	else:
		if is_instance_valid(player_body) and n_agent != null and spawn_delay != null and spawn_delay.time_left <= 0 and on_contact_hit_delay_timer.time_left <= 0:
			if awareness_raycast != null:
				awareness_raycast.look_at(player_body.global_position)
			match thinking_state:
				ThinkState.Neutral:
					# Check if we could find the player
					if is_player_seen() and is_node_ready():
						thinking_switch_timer.start(randi_range(PLAYER_DETECTED_DELAY_MIN, PLAYER_DETECTED_DELAY_MAX))
					
				ThinkState.Targeting:
					pass
					
			#if cur_knock_duration > 0.0:
				#_knockback_proccess(delta)
			if n_agent.target_position != Vector2.INF and decision_timer.time_left <= 0:
				move_to_ntarget()
			# We have an invalid desitination position, try to find another
			elif n_agent.target_position == Vector2.INF:
				decide_movement()
				
		animate()


func decide_movement():
	var desired_movement_position: Vector2 = Vector2.INF
	
	if health <= 0:
		return desired_movement_position
		
	pathing_limit_timer.stop()
	
	match thinking_state:
		ThinkState.Neutral:
			## If we have not yet found the player
			if thinking_switch_timer.time_left <= 0:
				#for i in 10:
				desired_movement_position = make_wander_path()
				if desired_movement_position == Vector2.INF:
					decision_timer.start(1)
		ThinkState.Targeting:
			var chance_rolled: int = randi_range(0, 100)
			if chance_rolled > 90:
				decision_timer.start(DECISION_TIME_DEFAULT)
			elif chance_rolled > 70:
				desired_movement_position = make_player_path()
			else:
				desired_movement_position = make_player_path()
	
	set_pathing_time(desired_movement_position)
	
	return desired_movement_position

func set_pathing_time(target_position: Vector2) -> float:
	var time: float = 0.1
	if target_position != Vector2.INF:
		# Time to get to the destination
		var speed: float = moving_speed
		var distance: float = global_position.distance_to(target_position)
		
		if speed != 0:
			time = (distance/speed)
			# Redo path faster as
			if thinking_state == ThinkState.Targeting:
				time /= 2
		pathing_limit_timer.start(time)
	return time

func animate():
	if not anim:
		return
	
	if velocity.length() > 0 and health > 0:
		anim.play("walk")
	else:
		anim.play("idle")
	
	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true

func _on_hitbox_entering(body: Node2D):
	if health <= 0:
		return
	if body is BasePlayer2D:
		var delay = get_attack_time()
		on_contact_hit_delay_timer.start(delay)

func _on_contact_hitbox_timeout():
	var bodies: Array[Node2D] = on_contact_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body is BasePlayer2D:
			var player: BasePlayer2D = body as BasePlayer2D
			player._on_getting_hit(get_contact_damage())
			var dir = global_position.direction_to(body.global_position)
			player.knockback_applied(dir, KNOCKBACK_FORCE, 0.1)
			#global_position += dir * (global_position.distance_to(body.global_position)/2)
			
			decision_timer.start(DECISION_TIME_DEFAULT)

func default_decision_making():
	match thinking_state:
		ThinkState.Neutral:
			decision_timer.start(DECISION_TIME_DEFAULT)
		ThinkState.Targeting:
			decision_timer.start(0.1)
			
func _n_navigation_reached():
	default_decision_making()

func _on_decision_timeout():
	decide_movement()

func _on_pathing_limit_timeout():
	default_decision_making()

# Switch the states
func _on_thinking_timeout():
	match thinking_state:
		ThinkState.Neutral:
			thinking_state = ThinkState.Targeting
			#awareness_raycast.target_position = Vector2(AWARENESS_TARGET_DISTANCE, 0)
		ThinkState.Targeting:
			thinking_state = ThinkState.Neutral
			#awareness_raycast.target_position = Vector2(AWARENESS_NEUTRAL_DISTANCE, 0)
		_: 
			thinking_state = ThinkState.Neutral
			#awareness_raycast.target_position = Vector2(AWARENESS_NEUTRAL_DISTANCE, 0)
	decide_movement()

func debug():
	pass
