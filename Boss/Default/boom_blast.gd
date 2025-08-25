extends BaseBlast2D

class_name BoomBlast2D


func _on_body_entered(body):
	damage_player(body)
