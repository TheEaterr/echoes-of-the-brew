# game.gd
extends Node2D


func _on_button_pressed() -> void:
	%GameOver.hide()
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
