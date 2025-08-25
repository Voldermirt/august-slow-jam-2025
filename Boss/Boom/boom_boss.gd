extends BaseBoss2D

class_name BoomBoss2D

@onready var boom_boss_bullet_scene = preload("res://Boss/Boom/boom_boss_projectile.tscn")
@onready var projectile_cd = $ProjectileCD

const DRAGON_BOSS_MAX_HEALTH = 1000

func get_max_health():
	return DRAGON_BOSS_MAX_HEALTH

func get_blast_cd() -> float:
	return randf_range(4, 8)

func _on_getting_hit(damage: float, bypass_invincibility=false, hit_by=""):
	if (bypass_invincibility or (not is_invincible)) and health > 0:
		health -= damage
		if health <= 0:
			_on_death()
		else:
			if hurt_sound:
				hurt_sound.play()

func _on_player_entering_area(body: Node2D):
	if body is BasePlayer2D:
		is_player_in_arena = true
		thinking_state = ThinkState.Targeting
		player_body = body
		projectile_cd.start()

func _on_player_exiting_area(body: Node2D):
	if body is BasePlayer2D:
		is_player_in_arena = false
		thinking_state = ThinkState.Neutral
		projectile_cd.stop()

func _on_projectile_cd_timeout() -> void:
	if not player_body:
		return
	# if it dies stop shooting
	if health <= 0:
		projectile_cd.stop()
		return
	
	$AttackSound.play()
	var boom_boss_projectile: = boom_boss_bullet_scene.instantiate()
	var destination = player_body.global_position
	
	boom_boss_projectile.direction = global_position.direction_to(destination)
	boom_boss_projectile.global_position = global_position
	Globals.get_2d_root().add_child(boom_boss_projectile)
	
