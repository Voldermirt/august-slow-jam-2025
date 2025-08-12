extends BaseWeapon2D
class_name PortalGun

const Bullet := preload("res://Player/Portal/portal_bullet.tscn")

@export var blue_color : Color
@export var orange_color : Color

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		shoot_portal(false)
	if Input.is_action_just_pressed("secondary"):
		shoot_portal(true)

func shoot_portal(is_orange):
	delete_existing_portal(is_orange)
	var bullet = Bullet.instantiate()
	bullet.is_orange = is_orange
	bullet.color = orange_color if is_orange else blue_color
	Globals.get_2d_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = Vector2.RIGHT.rotated(global_rotation)

func delete_existing_portal(orange):
	for portal in get_tree().get_nodes_in_group("portal_instance"):
		if portal.is_orange == orange:
			portal.queue_free()
