extends Node

class_name Potion

@export var color : String = "empty"
@export var ingredients : Array = []
@export var cooking_level : int = 0
@export var is_cooking : bool = false
@export var timer : Timer
@export var animation_sprite: AnimatedSprite2D
@export var potion_sprite: Sprite2D

var available_colors = ["empty", "purple", "blue", "green"]
var available_ingredients = ["mushroom", "flower", "root", "eyeball", "cristal"]

var potion_textures = {
	"purple_high": preload("res://assets/potion_purple_high.png"),
	"blue_high": preload("res://assets/potion_blue_high.png"),
	"green_high": preload("res://assets/potion_green_high.png"),
	"empty": preload("res://assets/potion_empty.png")
}

func _init():
	color = "empty"
	ingredients = []
	timer = Timer.new()
	timer.wait_time = 0.2
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	add_child(timer)
	
func update_potion_animation():
	if color == "empty":
		potion_sprite.visible = true
		potion_sprite.texture = potion_textures["empty"]
	else:
		if cooking_level < 33:
			potion_sprite.texture = potion_textures[color + "_high"]
		elif cooking_level < 66:
			potion_sprite.visible = false
			animation_sprite.visible = true
			animation_sprite.play(color + "_mid")
		elif cooking_level < 100:
			animation_sprite.play(color + "_low")
		else: 
			animation_sprite.visible = false
			potion_sprite.visible = true
			potion_sprite.texture = potion_textures["empty"]

	
func start_cooking():
	if not is_cooking:
		is_cooking = true
		timer.start()
		

func _on_Timer_timeout():
	if cooking_level < 100:
		cooking_level += 1
		update_potion_animation()
	else:
		timer.stop()
		is_cooking = false
		
func set_color(new_color : String):
	if new_color in available_colors:
		color = new_color
		
func add_ingredients(new_ingredient : String):
	if new_ingredient in available_ingredients and len(ingredients) < 2 :
		ingredients.append(new_ingredient)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
