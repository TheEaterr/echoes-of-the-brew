# game.gd
extends Node2D

func reset_game():
	%Counter/SpawnClientTimer.stop()
	%Counter/TimeTrialCountdown.stop()
	%Counter.global_score = 0
	%Counter/ScoreLabel.text = "Score: 0"
	for client in %Counter.clients:
		client.queue_free()
	%Counter.clients = []
	if %Assembly/PotionSpotControl/PotionSpot.current_potion:
		%Assembly/PotionSpotControl/PotionSpot.current_potion.queue_free()
		%Assembly/PotionSpotControl/PotionSpot.current_potion = null
	%Cooking.delete_all_potions()
	while %Counter.add_empty_potion():
		pass

func _on_restart_button_pressed() -> void:
	%GameOver.hide()
	reset_game()

func _on_infinite_button_pressed() -> void:
	%MainMenu.hide()
	Global.mode = "infinite"
	%Counter/ClientsServedLabel.show()
	%Counter/Button.hide()
	%Counter/SpawnClientTimer.start()
	%Counter._on_take_order_pressed()
	%Counter._on_take_order_pressed()
	%Counter._on_take_order_pressed()


func _on_time_trial_button_pressed() -> void:
	%MainMenu.hide()
	Global.mode = "time_trial"
	%Counter/ClientsServedLabel.hide()
	%Counter/Button.show()
	%Counter/TimeTrialCountdown.start()


func _on_main_menu_button_pressed() -> void:
	reset_game()    
	%GameOver.hide()
	%MainMenu.show()
