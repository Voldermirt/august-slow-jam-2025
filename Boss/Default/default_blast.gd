extends BaseBlast2D

class_name DefaultBlast2D

pass


func _on_body_entered(body):
	damage_player(body)
