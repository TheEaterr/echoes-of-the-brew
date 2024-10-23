extends Control

# For the assembly
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	print("Dropping data")
	if $PotionSpot.current_potion:
		$PotionSpot.current_potion.set_color("purple")

# Returns a boolean by examining the data being dragged to see if it's valid
# to drop here.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true
	# return current_potion && data in current_potion.available_colors
	
