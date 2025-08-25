extends BaseBoss2D

class_name BoomBoss2D

func _on_getting_hit(damage: float, bypass_invincibility=false, hit_by=""):
	if (bypass_invincibility or (not is_invincible)) and health > 0:
		health -= damage
		if health <= 0:
			_on_death()
		else:
			if hurt_sound:
				hurt_sound.play()
