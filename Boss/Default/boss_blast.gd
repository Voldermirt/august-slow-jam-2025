extends Area2D

class_name BaseBlast2D

const BASE_BLAST_DMG: float = 50
const BASE_BLAST_WINDUP: float = 0

const PERSISTANCE_TIME_MAX: int = 1
const PERSISTANCE_TIME_MIN: int = 1

var active_collision_mask: int
var active_collision_layer: int

# How long will the blast be telegraphed before it deals damage
var wind_up_timer: Timer
# How long will the blast be active and deal damage
var persistance_timer: Timer

func get_persistance_time() -> int:
	return randi_range(PERSISTANCE_TIME_MIN, PERSISTANCE_TIME_MAX)

func get_windup_time():
	return BASE_BLAST_WINDUP

func get_damage():
	return BASE_BLAST_DMG
	
func aim(aiming_position: Vector2, facing_right := false):
	look_at(aiming_position)
	while rotation_degrees > 360:
		rotation_degrees -= 360
	while rotation_degrees < 0:
		rotation_degrees += 360
	if facing_right:
		rotation_degrees = clamp(rotation_degrees, 60, 300)
	else:
		rotation_degrees = clamp(rotation_degrees, 120, 210)
	
func _ready():
	#collision_layer = 0
	#collision_mask = 0 
	#monitoring = false
	
	wind_up_timer = Timer.new()
	wind_up_timer.one_shot = true
	wind_up_timer.autostart = false
	wind_up_timer.timeout.connect(_on_windup_timeout)
	
	persistance_timer = Timer.new()
	persistance_timer.one_shot = true
	persistance_timer.autostart = false
	persistance_timer.timeout.connect(_on_persistance_timeout)
	
	add_child(wind_up_timer)
	add_child(persistance_timer)
	
	wind_up_timer.start(get_windup_time())

func damage_player(body: Node):
	if body is BasePlayer2D:
		body._on_getting_hit(get_damage(), false, "FirstBoss")
	
func _on_windup_timeout():
	#collision_layer = active_collision_layer
	#collision_mask = active_collision_mask
	
	monitoring = true
	modulate.r = 1
	persistance_timer.start(get_persistance_time())

func _on_persistance_timeout():
	queue_free()
