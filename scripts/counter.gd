extends Control

var client_scene = preload("res://scenes/client.tscn")
var potion_scene = preload("res://scenes/potion.tscn") 
var queue_offset = 300 # Espace entre les clients dans la file d'attente
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
func remove_client(client, potion, timeout=false):
	
	# Score de satisfaction et texte
	var satisfaction_score = 0
	var label_text = ""
	if timeout:
		satisfaction_score = -10
		label_text = "How slow... I'm off!\n-10"
	else:
		var result = calculate_satisfaction_score(client.waiting_time, potion, client)
		satisfaction_score = result[0]  # Le score de satisfaction
		label_text = result[1]          # Le texte du commentaire

	global_score += satisfaction_score
	if Global.mode == "infinite":
		global_score = min(max(-150, global_score), 100)
	$Score/ScoreLabel.text = str(global_score)
	$EsteemBar/ProgressBar.value = global_score
	clients_served += 1
	$ClientsServed/ClientsServedLabel.text = str(clients_served)
	
	# Jouer l'animation
	# Jouer l'animation avec le bon texte
	client.show_label(label_text)
	# Attendre 2 secondes
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
	$ScoreToReach/ScoreToReachLabel.text = str(score_goal)
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


	
func calculate_satisfaction_score(waiting_time: float, potion: Potion, client: CharacterBody2D) -> Array:
	var score = int(waiting_time)
	var label_text = ""

	# Comparaison des ingrédients
	var missing_ingredients = 0
	var extra_ingredients = 0
	
	for ingredient in client.ordered_ingredients:
		if ingredient not in potion.ingredients:
			missing_ingredients += 1

	for ingredient in potion.ingredients:
		if ingredient not in client.ordered_ingredients:
			extra_ingredients += 1

	var ingredient_penalty = (missing_ingredients + extra_ingredients) * 10
	score += ingredient_penalty
	
	# Comparaison des couleurs
	var color_penalty = 0
	if client.ordered_color != potion.color:
		color_penalty = 40
	score += color_penalty

	# Pénalité de cuisson
	var cooking_level_penalty = abs(client.ordered_cooking_level / 33 - potion.cooking_level / 33) * 10
	score += cooking_level_penalty 
	
	# Bonus de cuisson parfaite
	var cooking_bonus_time = 10 * (client.ordered_cooking_level / 33) if cooking_level_penalty == 0 else 0
	score = 40 - score + cooking_bonus_time

	# Définition des messages possibles avec une sélection aléatoire
	var penalty_messages = []
	if waiting_time > 40:
		penalty_messages.append("So slow!\n")
	if missing_ingredients > 0:
		penalty_messages.append("Missing ingredients!\n")
	if extra_ingredients > 0:
		penalty_messages.append("Didn’t ask for extra!\n")
	if color_penalty > 0:
		penalty_messages.append("Wrong color!\n")
	if cooking_level_penalty > 0:
		penalty_messages.append("Undercooked!\n" if potion.cooking_level < client.ordered_cooking_level else "Overcooked!\n")
	if score <=0:
		penalty_messages.append("Never coming back!\n")

	# Si aucune pénalité spécifique, ajoute un commentaire général selon le score
	if penalty_messages.size() == 0:
		if score > 30:
			label_text = "Perfect!\n"
		elif score > 20:
			label_text = "Excellent!\n"
		elif score > 0:
			label_text = "Yummy!\n"

	else:
		# Choix d’un commentaire de pénalité aléatoire
		label_text = penalty_messages[randi() % penalty_messages.size()] + " "

	# Ajout du score au commentaire
	if score >= 0:
		label_text += "+ "
		label_text += str(abs(score))
	else:
		label_text += "- "
		label_text += str(abs(score))

	return [score, label_text]



func _on_spawn_client_timer_timeout() -> void:
	_on_take_order_pressed()
	$SpawnClientTimer.wait_time = max($SpawnClientTimer.wait_time - 2, min_timer)
	$SpawnClientTimer.start()

func _on_time_trial_countdown_timeout() -> void:
	time_remaining -= 1
	if time_remaining == 0:
		%GameOver.show()
		$TimeRemaining/TimeRemainingLabel.text = str(time_remaining)
	else:
		if global_score >= score_goal:
			time_remaining = 60
			goal_reached += 1
			score_goal += 50 + goal_reached * 10
			$ScoreToReach/ScoreToReachLabel.text = str(score_goal)
		$TimeRemaining/TimeRemainingLabel.text = str(time_remaining)
