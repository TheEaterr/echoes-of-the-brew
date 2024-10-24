extends DraggablePotion

class_name Potion

@export var color : String = "empty"
@export var ingredients : Array = []
@export var cooking_level : int = 0
@export var is_cooking : bool = false
@export var timer : Timer
@export var potion_sprite: Sprite2D

var available_colors = ["empty", "purple", "blue", "green"]
var available_ingredients = ["bones", "flower", "roots", "eyeball", "gems", "leaves"]
var ingredient_sprites = []
var ingredient_textures = {
	"bones": preload("res://assets/bones.png"),
	"flower": preload("res://assets/flower.png"),
	"roots": preload("res://assets/roots.png"),
	"eyeball": preload("res://assets/eyeball.png"),
	"gems": preload("res://assets/gems.png"),
	"leaves": preload("res://assets/leaves.png")
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
		$AnimatedSprite2D.play("empty")
	else:
		if cooking_level < 33:
			$AnimatedSprite2D.play(color + "_high")
		elif cooking_level < 66:
			$AnimatedSprite2D.visible = true
			$AnimatedSprite2D.play(color + "_mid")
		elif cooking_level < 100:
			$AnimatedSprite2D.play(color + "_low")
		else: 
			$AnimatedSprite2D.play("empty")
	for i in range(2):
		if i < len(ingredients):
			ingredient_sprites[i].texture = ingredient_textures[ingredients[i]]
			ingredient_sprites[i].visible = true
		else:
			ingredient_sprites[i].visible = false

	
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
		update_potion_animation()
		
func add_ingredients(new_ingredient : String):
	if new_ingredient in available_ingredients and len(ingredients) < 2 :
		ingredients.append(new_ingredient)
		update_potion_animation()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	ingredient_sprites = [$Ingredient1, $Ingredient2]
	update_potion_animation()
