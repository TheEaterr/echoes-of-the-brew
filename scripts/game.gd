# game.gd
extends Node2D

var client_scene = preload("res://scenes/client.tscn")
var queue_offset = 200 # Espace entre les clients dans la file d'attente
var current_queue_position = Vector2(-100, 100) # Position initiale des clients dans la file
var clients = []  # Liste des clients en file


# Fonction appelée quand on clique sur le bouton "take order"
func _on_take_order_pressed():
	# Instancier un nouveau client
	var new_client = client_scene.instantiate()
	add_child(new_client)

	# Positionner le client à l'endroit de départ hors de la file
	new_client.position = Vector2(500, 100) # Droite de l'écran
	new_client.client_index = clients.size()
	new_client.move_to_position(Vector2(-300 + queue_offset * clients.size(), 100))
	clients.append(new_client)

# Fonction pour supprimer un client
func remove_client(client):
	print("Suppression du client : ", client)
	print("Temps d'attente: ", client.waiting_time)
	var client_index = client.client_index
	clients.erase(client)  # Retire le client de la liste
	client.queue_free()  # Supprime le client de la scène
	# Réajuste la position des clients restants
	for i in range(client_index, clients.size()):
		clients[i].client_index = i  # Met à jour l'indice
		clients[i].move_to_position(Vector2(-300 + queue_offset * i, 100))  # Déplace le client vers la nouvelle position
		print("Client déplacé : ", clients[i])

# Lien entre le bouton et la fonction
func _ready():
	$Button.connect("pressed", Callable(self, "_on_take_order_pressed"))

# Fonction pour mettre en pause tous les chronomètres des clients
func pause_all_clients():
	for client in clients:
		client.pause_timer()

# Fonction pour reprendre les chronomètres des clients
func resume_all_clients():
	for client in clients:
		client.resume_timer()
