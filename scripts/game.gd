# game.gd
extends Node2D

var potion_scene = preload("res://scenes/potion.tscn")
var obtained_score: int = 0

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
	%GameOver/VBoxContainer/HBoxContainer/SendScoreButton.disabled = false


func game_over() -> void:
	get_tree().paused = true
	obtained_score = %Counter.global_score
	%GameOver/VBoxContainer/ScoreLabel.text = "Achieved Score: " + str(obtained_score)
	%GameOver.show()
	$GameOverPlayer.play()


func _on_restart_button_pressed() -> void:
	$ClickPlayer.play()
	%GameOver.hide()
	%Options.hide()
	reset_game()
	start_game()


func _on_main_menu_button_pressed() -> void:
	$ClickPlayer.play()
	reset_game()    
	%GameOver.hide()
	%MainMenu.show()
	
func start_game() -> void:
	%Counter/SpawnClientTimer.paused = false
	%Counter/SpawnClientTimer.start()
	$ClickPlayer.play()

	%Counter/Button.disabled = true
	await get_tree().create_timer(1.0).timeout
	%Counter._on_take_order_pressed()
	%Counter/Button.disabled = false


func _on_counter_game_over() -> void:
	game_over()


func _on_start_button_pressed() -> void:
	%MainMenu.hide()
	%Story.show()

func _on_options_pressed() -> void:
	if %MainMenu.visible || %GameOver.visible || %Story.visible:
		return
	$ClickPlayer.play()
	get_tree().paused = true
	%Options.show()


func _on_continue_button_pressed() -> void:
	$ClickPlayer.play()
	get_tree().paused = false
	%Options.hide()


func _on_got_it_button_pressed() -> void:
	%Story.hide()
	start_game()


func _on_options_main_menu_button_pressed() -> void:
	$ClickPlayer.play()
	reset_game()
	%Options.hide()
	%MainMenu.show()


func _on_leaderboard_button_pressed() -> void:
	$ClickPlayer.play()
	get_scores()
	%MainMenu.hide()
	%Leaderboard.show()

func upload_score(player_name: String, score: int) -> void:
	var headers = ["Content-Type: application/json"]
	var body = {
		"player": player_name,
		"score": score
	}
	%GameOver/AddScoreHTTPRequest.request("https://echoes.maoune.fr/score/add/", headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func get_scores() -> void:
	%Leaderboard/GetScoreHTTPRequest.request("https://echoes.maoune.fr/score/list")

func _on_leaderboard_http_request_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var scores = JSON.parse_string(body.get_string_from_utf8())
		var current_label_index = 1
		for score in scores:
			var player_name = score["player"]
			var player_score = score["score"]
			var new_score = %Leaderboard/VBoxContainer/Scores.get_node("Score" + str(current_label_index))
			new_score.text = player_name + " - " + str(player_score)
			current_label_index += 1
		for i in range(current_label_index, 11):
			var new_score = %Leaderboard/VBoxContainer/Scores.get_node("Score" + str(i))
			new_score.text = "Empty"
	else:
		print("Error: " + str(response_code))


func _on_gameover_http_request_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		%GameOver/VBoxContainer/SendingStatus.text = "Score sent successfully!"
	else:
		%GameOver/VBoxContainer/SendingStatus.text = "Error: " + str(response_code)
		print("Error: " + str(response_code))


func _on_leaderboard_main_menu_button_pressed() -> void:
	$ClickPlayer.play()
	%Leaderboard.hide()
	for i in range(1, 11):
		var new_score = %Leaderboard/VBoxContainer/Scores.get_node("Score" + str(i))
		new_score.text = "Loading..."
	%MainMenu.show()


func _on_send_score_button_pressed() -> void:
	$ClickPlayer.play()
	%GameOver/VBoxContainer/HBoxContainer/SendScoreButton.disabled = true
	upload_score($GameOver/VBoxContainer/HBoxContainer/LineEdit.text, obtained_score)
	%GameOver/VBoxContainer/SendingStatus.show()
