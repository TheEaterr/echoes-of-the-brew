extends CharacterBody2D

# Variables pour gérer les animations et l'état du client
var client_index = -1 # Indice du client dans la file, assigné depuis le script principal
var move_speed = 300 # Vitesse de déplacement du client
var target_position = Vector2() # Position cible (dans la file d'attente)

# Fonction pour déplacer le client vers sa place
func move_to_position(target_pos: Vector2):
	target_position = target_pos
	$AnimatedSprite2D.play("walking_left")

# Fonction appelée à chaque frame pour gérer le déplacement
func _process(delta):
	if position.distance_to(target_position) > 1:
		position = position.move_toward(target_position, move_speed * delta)
	else:
		# Arrêter l'animation de marche une fois arrivé
		$AnimatedSprite2D.stop()
		show_order_icon()

# Fonction pour afficher la bulle de commande (une fois le client en place)
func show_order_icon():
	$OrderIcon.show() 

# Fonction pour détecter un clic sur le client
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Client cliqué : ", self)
		get_parent().remove_client(self)  # Appelle remove_client depuis la scène parent (game.gd)
		
func _ready():
	# Connecte le signal pour détecter les clics sur l'aire
	$Area2D.connect("input_event", Callable(self, "_on_area_2d_input_event"))
