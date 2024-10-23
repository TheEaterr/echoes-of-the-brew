extends Control

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if $PotionSpot.current_potion and data in $PotionSpot.current_potion.available_colors:
		if $PotionSpot.current_potion.color == "empty":
			$PotionSpot.current_potion.set_color(data)

# Returns a boolean by examining the data being dragged to see if it's valid
# to drop here.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return $PotionSpot.current_potion && data in $PotionSpot.current_potion.available_colors
