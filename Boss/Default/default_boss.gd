extends BaseBoss2D

class_name DefaultBoss2D

const DRAGON_BOSS_MAX_HEALTH = 1000

func get_max_health():
	return DRAGON_BOSS_MAX_HEALTH

func _process(delta: float) -> void:
	if health <= DRAGON_BOSS_MAX_HEALTH / 2:
		is_invincible = true

func get_blast_cd() -> float:
	return randf_range(1, 2)
