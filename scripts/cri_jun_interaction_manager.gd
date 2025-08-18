extends Area2D

""" 
	This class is the framework for creating interactions between objects if 
	their InteractionManagers overlap. The one initiating the interaction would 
	be the player character usually.
	
	Every InteractionManger must only be on layer 8 and interact with layer 8.
"""

class_name InteractionManager

# The current InteractionManager overlapped on this one
var current_interaction: InteractionManager

# Can be called from the parent script
# Calls the recieve_interaction() on the InteractionManager overlapping this one
func initiate_interaction() -> void:
	if current_interaction != null:
		current_interaction.receive_interaction()


# Defines actions that happen when an interaction occurs on this InteractionManager
func receive_interaction() -> void:
	print("No interaction reception behavior defined.")


# Stores the InteractionManager 
func _on_area_entered(area: Area2D) -> void:
	current_interaction = area

# Removes the InteractionManager if its too far away
func _on_area_exited(area: Area2D) -> void:
	if current_interaction == area:
		current_interaction = null
