# game.gd
extends Node2D

var potion_scene = preload("res://scenes/potion.tscn") 

func reset_game():
	%Counter/SpawnClientTimer.stop()
	%Counter/TimeTrialCountdown.paused = true
	%Counter.global_score = 0
	%Counter.goal_reached = 0
	%Counter.score_goal = 50
	%Counter.time_remaining = 60
	%Counter.clients_served = 0
	%Counter/Score/ScoreLabel.text = "0"
	%Counter/EsteemBar/ProgressBar.value = 0
	for client in %Counter.clients:
		client.queue_free()
	%Counter.clients = []
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


func _on_restart_button_pressed() -> void:
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
	%Counter/SpawnClientTimer.start()
	%Counter._on_take_order_pressed()
	%Counter._on_take_order_pressed()
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

func _on_main_menu_button_pressed() -> void:
	reset_game()    
	%GameOver.hide()
	%MainMenu.show()
	
