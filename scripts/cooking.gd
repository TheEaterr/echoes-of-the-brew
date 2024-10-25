extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func pause_all_potions():
	for slot in $HBoxContainer.get_children():
		var spot = slot.get_node("PotionSpot")
		if spot.current_potion != null:
			spot.current_potion.pause_cooking()


func unpause_all_potions():
	for slot in $HBoxContainer.get_children():
		var spot = slot.get_node("PotionSpot")
		if spot.current_potion != null:
			spot.current_potion.unpause_cooking()


func toggle_potions_view(showPotions: bool):
	for slot in $HBoxContainer.get_children():
		var spot = slot.get_node("PotionSpot")
		if spot.current_potion != null and spot.current_potion != Global.dragged_potion:
			if showPotions:
				spot.current_potion.show()
			else:
				spot.current_potion.hide()


func delete_all_potions():
	for slot in $HBoxContainer.get_children():
		var spot = slot.get_node("PotionSpot")
		if spot.current_potion != null:
			spot.current_potion.queue_free()
			spot.current_potion = null


func _on_button_pressed() -> void:
	hide()
	toggle_potions_view(false)
	%Assembly.show()
	if %Assembly/PotionSpotControl/PotionSpot.current_potion:
		%Assembly/PotionSpotControl/PotionSpot.current_potion.show()
