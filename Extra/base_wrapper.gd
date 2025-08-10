extends Node

class_name BaseWrapper

const INVALID_CHILD_ERROR: String = "The wrapper MUST have a single child player/object scene that can be switched between games!"

# Empty function to be overriden by the subclass
func switch_to(game: Globals.GameList):
	push_error("This is an abstract method, only should be overriden and called in the subclass")
