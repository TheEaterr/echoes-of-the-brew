# game.gd
extends Node2D

var potion_scene = preload("res://scenes/potion.tscn")

func reset_game():
	%Counter.reset_parameters()
	if %Assembly/PotionSpotControl/PotionSpot.current_potion:
		%Assembly/PotionSpotControl/PotionSpot.current_potion.queue_free()
		%Assembly/PotionSpotControl/PotionSpot.current_potion = null
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
	%Counter/SpawnClientTimer.paused = true
	%Counter/TimeTrialCountdown.paused = true
	%GameOver.show()
	$GameOverPlayer.play()


func _on_restart_button_pressed() -> void:
	$ClickPlayer.play()
	%GameOver.hide()
	reset_game()
	if Global.mode == "infinite":
		_on_infinite_button_pressed()
	else:
		_on_time_trial_button_pressed()

func _on_infinite_button_pressed() -> void:
	%MainMenu.hide()
	Global.mode = "infinite"
	%Counter/EsteemBar.show()
	%Counter/ClientsServed.show()
	%Counter/Button.hide()
	%Counter/TimeRemaining.hide()
	%Counter/ScoreToReach.hide()
	%Counter/Score.hide()
	%Counter/SpawnClientTimer.paused = false
	%Counter/SpawnClientTimer.start()
	$ClickPlayer.play()

	await get_tree().create_timer(1.0).timeout
	%Counter._on_take_order_pressed()
	await get_tree().create_timer(1.0).timeout
	%Counter._on_take_order_pressed()
	await get_tree().create_timer(1.0).timeout
	%Counter._on_take_order_pressed()


func _on_time_trial_button_pressed() -> void:
	%MainMenu.hide()
	Global.mode = "time_trial"
	%Counter/EsteemBar.hide()
	%Counter/TimeTrialCountdown.paused = false
	%Counter/ClientsServed.hide()
	%Counter/Button.show()
	%Counter/TimeTrialCountdown.start()
	%Counter/TimeRemaining.show()
	%Counter/TimeRemaining/TimeRemainingLabel.text = str(%Counter.time_remaining)
	%Counter/ScoreToReach.show()
	%Counter/Score.show()
	$ClickPlayer.play()

func _on_main_menu_button_pressed() -> void:
	$ClickPlayer.play()
	reset_game()    
	%GameOver.hide()
	%MainMenu.show()
	


func _on_counter_game_over() -> void:
	game_over()
