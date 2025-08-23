extends BasePlayer2D

# The default player game starts with
class_name DefaultPlayer2D

signal unlock_game(game: String)

@onready var default_weapon: DefaultSword = $DefaultSword

var killed_by_first_boss: int = 0

func _ready():
	super._ready()
	anim = $AnimatedSprite2D
	hurt_sound = $HurtSound

#func save_json_data() -> JSON:
	#var super_data: JSON = super.save_json_data()
	#return super_data

func _physics_process(delta):
	super._physics_process(delta)
	if not default_weapon.is_attacking():
		_weapon_rotation_process(default_weapon)

func _on_getting_hit(damage: float, bypass_invincibility=false, hit_by=""):
	if (bypass_invincibility or (not is_invincible)) and health > 0:
		health -= damage
		if health <= 0:
			if hit_by == "FirstBoss":
				killed_by_first_boss += 1
				if killed_by_first_boss >= 2:
					emit_signal("unlock_game", "boom")
			await get_tree().create_timer(0.25).timeout
			_on_death()
		else:
			if hurt_sound:
				hurt_sound.play()
			_start_damage_recovery()

func _on_death():
	if death_sound:
		death_sound.play()
	death.emit()
	# death animation here
	Globals.load_game()
