# client.gd
extends CharacterBody2D

# Variables pour gérer les animations, l'état du client et le chronomètre
var client_index = -1  # Indice du client dans la file, assigné depuis le script principal
var move_speed = 300  # Vitesse de déplacement du client
var target_position = Vector2()  # Position cible (dans la file d'attente)
var waiting_time = 0.0  # Chronomètre pour le temps d'attente
var timer_paused = false  # Variable pour savoir si le chronomètre est en pause

# Fonction pour déplacer le client vers sa place
func move_to_position(target_pos: Vector2):
	target_position = target_pos
	$AnimatedSprite2D.play("walking_left")

# Fonction appelée à chaque frame pour gérer le déplacement et le chronomètre
func _process(delta):
	if not timer_paused:
		waiting_time += delta  # Incrémente le temps d'attente si le chronomètre n'est pas en pause
	
	if position.distance_to(target_position) > 1:
		position = position.move_toward(target_position, move_speed * delta)
	else:
		# Arrêter l'animation de marche une fois arrivé
		$AnimatedSprite2D.stop()

# Fonction pour afficher la bulle de commande (une fois le client en place)
func show_order_icon():
	$Potion.show() 
	$Potion.cooking_level = randi() % 100
	$Potion.set_color($Potion.available_colors[randi() % ($Potion.available_colors.size() - 1) + 1])

# Fonction pour gérer la pause du chronomètre
func pause_timer():
	timer_paused = true

func resume_timer():
	timer_paused = false

func _ready():
	$PotionSpot.is_client = true
	# Connecte le signal pour détecter les clics sur l'aire
	show_order_icon()
	$PotionSpot.connect("received_potion_for_client", Callable(self, "_on_potion_received"))

func _on_potion_received(potion: DraggablePotion):
	# Quand le client reçoit une potion, on le supprime
	get_parent().remove_client(self)
	potion.queue_free() 
	
