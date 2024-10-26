extends Control

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if $PotionSpot.current_potion:
		if data in $PotionSpot.current_potion.available_colors:
			if $PotionSpot.current_potion.color == "empty":
				$BasePlayer.play(0.5)
				$PotionSpot.current_potion.set_color(data)
		elif data in $PotionSpot.current_potion.available_ingredients:
			if len($PotionSpot.current_potion.ingredients) < 2:
				$IngredientPlayer.play()
				$PotionSpot.current_potion.add_ingredients(data)

# Returns a boolean by examining the data being dragged to see if it's valid
# to drop here.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return $PotionSpot.current_potion && (data in $PotionSpot.current_potion.available_colors || data in $PotionSpot.current_potion.available_ingredients)
