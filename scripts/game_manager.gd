extends Node
class_name GameManager

enum Game {
	JAM,      # The "original" "game jam" game
	DOOM,     # Doom
	PORTAL,   # Portal
	CROSSING  # Animal Crossing
}

var available_games = [Game.JAM] # Games we can switch to

func load_game(new_game : Game):
	pass
