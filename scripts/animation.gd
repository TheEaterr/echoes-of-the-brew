extends Control

@export var display_time: float = 2.0  # Temps d'affichage du score
@onready var score_label = $Label
@onready var animation_player = $AnimationPlayer

func show_score(score: int):
	$Label.text = str(score)
	$AnimationPlayer.play("score_display")  # Joue l'animation
	
	# Attendre la fin de l'animation
	await $AnimationPlayer.animation_finished 
	queue_free()  # Supprime la scène après l'animation
