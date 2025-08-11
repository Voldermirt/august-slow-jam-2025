extends CharacterBody2D

class_name BaseEnemy2D


func _on_hit():
	queue_free()
