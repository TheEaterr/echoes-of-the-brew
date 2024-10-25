extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	hide()
	%Cooking.show()
	%Cooking.toggle_potions_view(true)
	if $PotionSpotControl/PotionSpot.current_potion:
		if $PotionSpotControl/PotionSpot.current_potion != Global.dragged_potion:
			$PotionSpotControl/PotionSpot.current_potion.hide()
