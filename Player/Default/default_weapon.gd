extends BaseWeapon2D
class_name DefaultSword

const SWORD_DAMAGE: float = 50

@onready var anim = $Rotatator/AnimationPlayer
@onready var block_col = $Rotatator/BlockCollision

func is_attacking():
	return anim.current_animation == "swing"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary"):
		attack()
	if Input.is_action_just_pressed("secondary"):
		block()

func attack():
	anim.play("swing")

func block():
	anim.play("block")
	block_col.process_mode = Node.AUTO_TRANSLATE_MODE_INHERIT

func reset():
	anim.play("idle")
	block_col.process_mode = Node.PROCESS_MODE_DISABLED

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["block", "swing"]:
		reset()

func _on_sword_body_entered(body: Node2D) -> void:
	if not is_attacking():
		return
	# Handle attack
	# To be implemented once enemies exist I guess
	if body is BaseEnemy2D:
		(body as BaseEnemy2D)._on_getting_hit(SWORD_DAMAGE)
