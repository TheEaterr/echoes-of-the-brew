extends Control

var client_scene = preload("res://scenes/client.tscn")
var potion_scene = preload("res://scenes/potion.tscn") 
var queue_offset = 250 # Espace entre les clients dans la file d'attente
var current_queue_position = Vector2(-100, 300) # Position initiale des clients dans la file
var clients = []  # Liste des clients en file
var global_score = 0
var min_timer = 5
var max_timer = 0
var clients_served = 0
var time_remaining = 60
var score_goal = 50
var goal_reached = 0

# Fonction appelée quand on clique sur le bouton "take order"
func _on_take_order_pressed():
	# Instancier un nouveau client
	var new_client = client_scene.instantiate()
	add_child(new_client)

	# Positionner le client à l'endroit de départ hors de la file
	new_client.position = Vector2(1200, 400) # Droite de l'écran
	new_client.client_index = clients.size()
	new_client.move_to_position(Vector2(200 + queue_offset * clients.size(), 400))
	clients.append(new_client)

# Fonction pour supprimer un client
func remove_client(client, potion):
	
	# Score de satisfaction
	var satisfaction_score = calculate_satisfaction_score(client.waiting_time, potion, client)
	print("satisfaction score :", satisfaction_score)
	global_score += satisfaction_score
	$ScoreLabel.text = "Score: " + str(global_score)
	clients_served += 1
	$ClientsServedLabel.text = "Clients served: " + str(clients_served)
	print("global_score: ", global_score)
	# Update global score
	$ScoreLabel.text = "Score : " + str(global_score)
	
	# Jouer l'animation
	# Définir le texte à afficher dans le label selon le score
	var label_text = ""
	if satisfaction_score > 0:
		label_text = "Yummy! + " + str(satisfaction_score)
	else:
		label_text = "Disgusting! - " + str(abs(satisfaction_score))

	# Jouer l'animation avec le bon texte
	client.show_label(label_text)
	
	# Attendre 2 secondes avant de continuer
	await get_tree().create_timer(2.0).timeout
	
	# Update graphique et suppression du client
	add_empty_potion()
	var client_index = client.client_index
	clients.erase(client)  # Retire le client de la liste
	client.queue_free()  # Supprime le client de la scène
	# Réajuste la position des clients restants
	for i in range(client_index, clients.size()):
		clients[i].client_index = i  # Met à jour l'indice
		clients[i].move_to_position(Vector2(200 + queue_offset * i, 400))  # Déplace le client vers la nouvelle position
	
	if global_score <= -150:
		%GameOver.show()

# Lien entre le bouton et la fonction
func _ready():
	$ScoreToReachLabel.text = "Score to reach: " + str(score_goal)
	max_timer = $SpawnClientTimer.wait_time
	$Button.connect("pressed", Callable(self, "_on_take_order_pressed"))

# Fonction pour mettre en pause tous les chronomètres des clients
func pause_all_clients():
	for client in clients:
		client.pause_timer()

# Fonction pour reprendre les chronomètres des clients
func resume_all_clients():
	for client in clients:
		client.resume_timer()


func add_empty_potion(restart = false):
	var inventoryGrid = %Inventory/InventoryGrid
	for slot in inventoryGrid.get_children():  # Parcourt tous les enfants de la scène
		var spot = slot.get_node("PotionSpot")  # Récupère le Potion
		if spot is PotionSpot and spot.current_potion == null:
			var new_potion = potion_scene.instantiate()  # Crée une nouvelle potion
			spot.current_potion = new_potion  # Associe la potion au PotionSpot
			new_potion.current_spot = spot
			add_child(new_potion)  # Ajoute la potion à la scène
			new_potion.global_position = spot.global_position  # Positionne la potion au même endroit que le PotionSpot
			return true # Sort de la fonction après avoir ajouté la potion
	return false


func calculate_satisfaction_score(waiting_time: float, potion: Potion, client: CharacterBody2D) -> float:
	var score = int(waiting_time)

	# Comparaison des ingrédients
	var missing_ingredients = 0
	var extra_ingredients = 0
	
	# Compter les ingrédients manquants et en trop
	for ingredient in client.ordered_ingredients:
		if ingredient not in potion.ingredients:
			missing_ingredients += 1

	for ingredient in potion.ingredients:
		if ingredient not in client.ordered_ingredients:
			extra_ingredients += 1
	# 10 secondes de pénalité par ingrédient en trop ou manquant
	var ingredient_penalty = (missing_ingredients + extra_ingredients) * 10
	score += ingredient_penalty
	
	# Comparaison des couleurs
	var color_penalty = 0
	if client.ordered_color != potion.color:
		color_penalty = 40
	score += color_penalty

	# 10 secondes de pénalité par tranche de niveau de cuisson de différence
	var cooking_level_penalty = abs(client.ordered_cooking_level / 33 - potion.cooking_level / 33)*10
	score += cooking_level_penalty 
	
	var cooking_bonus_time = 10*(client.ordered_cooking_level / 33) if cooking_level_penalty == 0 else 0
	return 40 - score + cooking_bonus_time


func _on_spawn_client_timer_timeout() -> void:
	_on_take_order_pressed()
	$SpawnClientTimer.wait_time = max($SpawnClientTimer.wait_time - 2, min_timer)
	$SpawnClientTimer.start()

func _on_time_trial_countdown_timeout() -> void:
	time_remaining -= 1
	if time_remaining == 0:
		%GameOver.show()
	else:
		if global_score >= score_goal:
			time_remaining = 60
			goal_reached += 1
			score_goal += 50 + goal_reached * 10
			$ScoreToReachLabel.text = "Score to reach: " + str(score_goal)
		$TimeRemainingLabel.text = "Time remaining: " + str(time_remaining)
