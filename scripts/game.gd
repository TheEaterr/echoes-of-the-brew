# game.gd
extends Node2D

var potion_scene = preload("res://scenes/potion.tscn")

func reset_game():
	get_tree().paused = false
	%Counter.reset_parameters()
	%Cooking.delete_all_potions()
	while %Counter.add_empty_potion():
		pass
	# Replace Potions with empty potions
	var inventoryGrid = %Inventory/InventoryGrid
	for slot in inventoryGrid.get_children():
		var spot = slot.get_node("PotionSpot")
		if spot is PotionSpot:
			if spot.current_potion != null:
				spot.current_potion.queue_free() 
			var new_potion = potion_scene.instantiate() 
			spot.current_potion = new_potion
			new_potion.current_spot = spot 
			add_child(new_potion) 
			new_potion.global_position = spot.global_position


func game_over() -> void:
	get_tree().paused = true
	%GameOver.show()
	$GameOverPlayer.play()


func _on_restart_button_pressed() -> void:
	$ClickPlayer.play()
	%GameOver.hide()
	%Options.hide()
	reset_game()
	_on_start_button_pressed()


func _on_main_menu_button_pressed() -> void:
	$ClickPlayer.play()
	reset_game()    
	%GameOver.hide()
	%MainMenu.show()
	


func _on_counter_game_over() -> void:
	game_over()


func _on_start_button_pressed() -> void:
	%MainMenu.hide()
	%Counter/SpawnClientTimer.paused = false
	%Counter/SpawnClientTimer.start()
	$ClickPlayer.play()

	%Counter/Button.disabled = true
	await get_tree().create_timer(1.0).timeout
	%Counter._on_take_order_pressed()
	%Counter/Button.disabled = false


func _on_options_pressed() -> void:
	if %MainMenu.visible || %GameOver.visible:
		return
	$ClickPlayer.play()
	get_tree().paused = true
	%Options.show()


func _on_continue_button_pressed() -> void:
	$ClickPlayer.play()
	get_tree().paused = false
	%Options.hide()
