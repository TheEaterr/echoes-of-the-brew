extends Control

var client_scene = preload("res://scenes/client.tscn")
var potion_scene = preload("res://scenes/potion.tscn") 
var queue_offset = 250 # Espace entre les clients dans la file d'attente
var current_queue_position = Vector2(-100, 300) # Position initiale des clients dans la file
var clients = []  # Liste des clients en file
var global_score = 0
var magic_power = 0
var esteem = 0
var min_timer = 3
var max_timer = 0
var goal_reached = 0

# Level 1: Very Negative
var level_1 = [
	"I always hated you",
	"You were a terrible teacher",
	"Our friendship was a mistake",
	"I regret meeting you",
	"You brought nothing but trouble",
	"Working with you was awful",
	"You ruined our group project",
	"I wish I hadn't known you",
	"You were the worst boss ever",
	"Our relationship was a disaster"
]

# Level 2: Negative
var level_2 = [
	"Things didn't work out between us",
	"We had our differences",
	"I didn't enjoy working with you",
	"Our time together was challenging",
	"You caused problems for me",
	"I found your teaching style harsh",
	"Our project together was stressful",
	"There were issues between us",
	"Your leadership left much to be desired",
	"Things ended badly for us"
]

# Level 3: Neutral
var level_3 = [
	"It's been a while since we last spoke",
	"Let's catch up on old times",
	"How have you been?",
	"Life has changed so much",
	"I remember those days fondly",
	"It feels like forever ago",
	"What have you been up to lately?",
	"Nice to see you again",
	"How about we reminisce?",
	"Good to reconnect"
]

# Level 4: Positive
var level_4 = [
	"I've missed our conversations",
	"You were always a great friend",
	"Our time together was memorable",
	"I enjoyed working with you",
	"Your teaching inspired me",
	"We had some good times",
	"It's nice to see your face again",
	"I value our past friendship",
	"You were a fantastic colleague",
	"Our time together was wonderful"
]

# Level 5: More Positive
var level_5 = [
	"You made my life better",
	"Your presence brightened the room",
	"I admired your work ethic",
	"We had great chemistry as friends",
	"You brought out the best in me",
	"Our collaboration was amazing",
	"Your guidance meant a lot to me",
	"Working with you was a pleasure",
	"I cherish our memories together",
	"You were an asset to our team"
]

# Level 6: Very Positive
var level_6 = [
	"I owe so much of my success to you",
	"Your support meant the world to me",
	"Our bond was truly special",
	"You changed my life for the better",
	"I can't imagine my journey without you",
	"Your leadership was inspiring",
	"We made a great team together",
	"I still value your advice",
	"You are one of the best people I know",
	"Our friendship is irreplaceable"
]

# Level 7: Most Positive
var level_7 = [
	"I had feelings for you",
	"Your smile always brightened my day",
	"You were my rock in tough times",
	"Our connection was deeper than friends",
	"I often thought about you",
	"I cared about you more than I let on",
	"Our time together was magical",
	"You were the best part of my past",
	"I had a crush on you for so long",
	"Seeing you again brings back wonderful feelings"
]

signal game_over

# Fonction appelée quand on clique sur le bouton "take order"
func _on_take_order_pressed() -> bool:
	if len(clients) > 5:
		return false
	# Instancier un nouveau client
	var new_client = client_scene.instantiate()
	add_child(new_client)

	# Positionner le client à l'endroit de départ hors de la file
	new_client.position = Vector2(1600, 400) # Droite de l'écran
	new_client.client_index = clients.size()
	new_client.move_to_position(Vector2(200 + queue_offset * clients.size(), 400))
	clients.append(new_client)
	$NewClientPlayer.play()
	
	$Button.disabled = true  # Désactive le bouton
	# Lance un timer pour réactiver le bouton après 1 seconde
	await get_tree().create_timer(1).timeout
	$Button.disabled = false  # Réactive le 
	return true

func reset_parameters():
	set_global_score(0)
	set_magic_power(0)
	set_esteem(0)
	$SpawnClientTimer.wait_time = max_timer
	$SpawnClientTimer.paused = true
	for client in clients:
		client.queue_free()
	clients = []

# Fonction pour supprimer un client
func remove_client(client, potion, timeout=false):
	
	# Score de satisfaction et texte
	var satisfaction_score = 0
	var label_text = ""
	if timeout:
		satisfaction_score = -50
	else:
		satisfaction_score = calculate_satisfaction_score(client.get_node("Timer").wait_time - client.get_node("Timer").time_left, potion, client)

	if satisfaction_score < -20:
		label_text = level_1[randi() % level_1.size()]
	elif satisfaction_score < 0:
		label_text = level_2[randi() % level_2.size()]
	elif satisfaction_score < 10:
		label_text = level_3[randi() % level_3.size()]
	elif satisfaction_score < 20:
		label_text = level_4[randi() % level_4.size()]
	elif satisfaction_score < 30:
		label_text = level_5[randi() % level_5.size()]
	elif satisfaction_score < 40:
		label_text = level_6[randi() % level_6.size()]
	else:
		label_text = level_7[randi() % level_7.size()]

	set_global_score(global_score + max(satisfaction_score, 0))
	var new_esteem = min(max(-150, esteem + satisfaction_score), 100)
	var new_magic_power = magic_power
	if esteem + satisfaction_score > 100:
		new_magic_power = magic_power + (esteem + satisfaction_score) - 100
	client.show_label(label_text, new_esteem - esteem, new_magic_power - magic_power)
	set_magic_power(new_magic_power)
	set_esteem(new_esteem)
	
	# Jouer l'animation
	# Jouer l'animation avec le bon texte
	if satisfaction_score < 0:
		client.play_hurt_animation()
	else:
		client.play_jump_animation()
	var potion_spot = client.get_node("PotionSpot")
	if potion_spot:
		potion_spot.queue_free()
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
	
	if esteem <= -150:
		game_over.emit()

# Lien entre le bouton et la fonction
func _ready():
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


func add_empty_potion(_restart = false):
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


func set_global_score(score: int):
	global_score = score
	$Score/ScoreLabel.text = str(global_score)


func set_magic_power(power: int):
	magic_power = power
	$MagicPower/MagicPowerLabel.text = str(magic_power)


func set_esteem(value: int):
	esteem = value
	$EsteemBar/ProgressBar.value = value

	
func calculate_satisfaction_score(waiting_time: float, potion: Potion, client: CharacterBody2D) -> int:
	var total_penalty = int(waiting_time)
	var score = 0

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
	total_penalty += ingredient_penalty
	
	# Comparaison des couleurs
	var color_penalty = 0
	if client.ordered_color != potion.color:
		color_penalty = 40
	total_penalty += color_penalty

	# Pénalité de cuisson
	@warning_ignore("integer_division")
	var cooking_level_penalty = abs(client.ordered_cooking_level / 33 - potion.cooking_level / 33) * 20
	total_penalty += cooking_level_penalty 
	
	# Bonus de cuisson parfaite
	var cooking_bonus_time = 10 * (client.ordered_cooking_level / 33) if cooking_level_penalty == 0 else 0
	score = 20 - total_penalty + cooking_bonus_time
	score = max(-50, score)

	# Définition des messages possibles avec une sélection aléatoire
	var has_problem = false
	if waiting_time > 40:
		has_problem = true
	if missing_ingredients > 0:
		has_problem = true
	if extra_ingredients > 0:
		has_problem = true
	if color_penalty > 0:
		has_problem = true
	if cooking_level_penalty > 0:
		has_problem = true

	# Choix du commentaire
	if not has_problem:
		score += 30

	if score > 20:
		$SuccessPlayer.play()
	elif score > 0:
		$MediumPlayer.play()
	else:
		$FailurePlayer.play()

	return score


func _on_spawn_client_timer_timeout() -> void:
	var new_client = await _on_take_order_pressed()
	$SpawnClientTimer.wait_time = max($SpawnClientTimer.wait_time - 1, min_timer)
	$SpawnClientTimer.start()
	if not new_client:
		$FullContainer.show()
		$FailurePlayer.play()
		set_esteem(min(max(-150, esteem - 50), 100))
		if esteem <= -150:
			game_over.emit()
		await get_tree().create_timer(1.0).timeout
		$FullContainer.hide()
