# client.gd
extends CharacterBody2D

# Variables pour gérer les animations, l'état du client et le chronomètre
var client_index = -1  # Indice du client dans la file, assigné depuis le script principal
var move_speed = 300  # Vitesse de déplacement du client
var target_position = Vector2()  # Position cible (dans la file d'attente)
var ordered_cooking_level = randi() % 100
var ordered_color : String = "empty"
var ordered_ingredients = []
var is_queuing = true
var zombie_type: int = 1
var still_walking = true
var animation_playing = false

# Fonction pour déplacer le client vers sa place
func move_to_position(target_pos: Vector2):
	target_position = target_pos
	$AnimatedSprite2D.play(str(zombie_type) + "_walking")
	
func play_hurt_animation():
	$AnimatedSprite2D.play(str(zombie_type) + "_hurt")
	animation_playing = true

func play_jump_animation():
	$AnimatedSprite2D.play(str(zombie_type) + "_jump")
	animation_playing = true

# Fonction appelée à chaque frame pour gérer le déplacement et le chronomètre
func _process(delta):
	if position.distance_to(target_position) > 1:
		position = position.move_toward(target_position, move_speed * delta)
	elif still_walking and not(animation_playing):
		# Arrêter l'animation de marche une fois arrivé
		$AnimatedSprite2D.play(str(zombie_type) + "_idle")
		still_walking = false

# Fonction pour afficher la bulle de commande (une fois le client en place)
func show_order_icon():
	$Potion.show() 
	$Potion.cooking_level = ordered_cooking_level
	$Potion.set_color(ordered_color)
	for ingredient in ordered_ingredients:
		$Potion.add_ingredients(ingredient)

func show_label(text, inc_esteem, inc_magic_power):
	$Potion.hide()
	$Label.show()
	$Label.text = text
	if inc_esteem < 0:
		$IncrementContainer/Esteem/EsteemLabel.text = "- " + str(abs(inc_esteem))
	else:
		$IncrementContainer/Esteem/EsteemLabel.text = "+ " + str(inc_esteem)
	if inc_magic_power < 0:
		$IncrementContainer/MagicPower/MagicPowerLabel.text = "- " + str(abs(inc_magic_power))
	else:
		$IncrementContainer/MagicPower/MagicPowerLabel.text = "+ " + str(inc_magic_power)
	if inc_esteem != 0:
		$IncrementContainer/Esteem.show()
	if inc_magic_power != 0:
		$IncrementContainer/MagicPower.show()
	if inc_esteem == 0 and inc_magic_power == 0:
		$IncrementContainer/Esteem.show()

func _ready():
	# Choix aléatoire des ingrédients commandés
	var random_chance = randi() % 100
	zombie_type = 1 + randi() % 3 

	if random_chance < 20:
		# 20% de chance de ne pas avoir d'ingrédients
		ordered_ingredients = []
	elif random_chance < 80:
		# 60% de chance d'avoir un seul ingrédient
		var random_index = randi() % $Potion.available_ingredients.size()
		ordered_ingredients = [$Potion.available_ingredients[random_index]]
	else:
		# 20% de chance d'avoir deux ingrédients différents
		var first_index = randi() % $Potion.available_ingredients.size()
		var second_index = first_index  # Assurez-vous qu'ils soient différents
		while second_index == first_index:
			second_index = randi() % $Potion.available_ingredients.size()
		
		ordered_ingredients = [
			$Potion.available_ingredients[first_index],
			$Potion.available_ingredients[second_index]
		]
	
	ordered_color = $Potion.available_colors[randi() % ($Potion.available_colors.size() - 1) + 1]

	$PotionSpot.is_client = true
	$PotionSpot/Sprite2D.hide()
	$PotionSpot/SpotCollision.shape = $CollisionShape2D.shape
	$PotionSpot/SpotCollision.global_position = $CollisionShape2D.global_position
	# Connecte le signal pour détecter les clics sur l'aire
	show_order_icon()
	$PotionSpot.connect("received_potion_for_client", Callable(self, "_on_potion_received"))
	$Label.hide()

func _on_potion_received(potion: Potion):
	# Quand le client reçoit une potion, on le supprime
	get_parent().remove_client(self, potion)
	potion.current_spot.current_potion = null
	potion.queue_free() 
	

func _on_timer_timeout() -> void:
	if is_queuing and get_tree().paused == false:
		is_queuing = false
		get_parent().remove_client(self, null, true)
