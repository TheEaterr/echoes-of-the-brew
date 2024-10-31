extends Area2D

class_name Potion

## A draggable sprite that can be dragged using the left mouse button.


## Emitted when the sprite is grabbed
signal grabbed
## Emitted when the sprite is released
signal released


## Whether or not it should be possible to grab the sprite
@export var grabbable := true
## Whether or not it should be possible to drag from the center of the sprite
@export var centerDrag := false
## The input button that will be used to grab the sprite
@export var input_method: MouseButton = MOUSE_BUTTON_LEFT

## The Sprite node that will be used to display the texture
var sprite := Sprite2D.new()
## The default collider. It is automatically created and updated to match the size of the sprite
var default_collider : CollisionShape2D
## Whether or not the sprite is currently grabbed
var is_grabbed := false :
	set(value):
		is_grabbed = value
		if is_grabbed:
			grabbed.emit()
		else:
			released.emit()


# Helps a bit to make the dragging less choppy
var grabbed_offset := Vector2.ZERO
# Mouse button pressed tracker, used to essentially replicate the behavior of 'is_action_just_released'
var mb_pressed = false

var current_spot: PotionSpot = null

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
	"bones": {
		"full": preload("res://assets/bones.png"),
		"primary": preload("res://assets/bones_primary.png"),
		"secondary": preload("res://assets/bones_secondary.png")
	},
	"flower": {
		"full": preload("res://assets/flower.png"),
		"primary": preload("res://assets/flower_primary.png"),
		"secondary": preload("res://assets/flower_secondary.png")
	},
	"roots": {
		"full": preload("res://assets/roots.png"),
		"primary": preload("res://assets/roots_primary.png"),
		"secondary": preload("res://assets/roots_secondary.png")
	},
	"eyeball": {
		"full": preload("res://assets/eyeball.png"),
		"primary": preload("res://assets/eyeball_primary.png"),
		"secondary": preload("res://assets/eyeball_secondary.png")
	},
	"gems": {
		"full": preload("res://assets/gems.png"),
		"primary": preload("res://assets/gems_primary.png"),
		"secondary": preload("res://assets/gems_secondary.png")
	},
	"leaves": {
		"full": preload("res://assets/leaves.png"),
		"primary": preload("res://assets/leaves_primary.png"),
		"secondary": preload("res://assets/leaves_secondary.png")
	}
}

func _init():
	color = "empty"
	ingredients = []
	timer = Timer.new()
	timer.wait_time = 0.3
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)
	
func update_potion_animation():
	if color == "empty":
		$AnimatedSprite2D.play("empty")
		$TopOutline.hide()
		$MidOutline.hide()
		$BottomOutline.hide()
	else:
		if cooking_level < 33:
			$AnimatedSprite2D.play(color + "_high")
			$TopOutline.show()
			$MidOutline.hide()
			$BottomOutline.hide()
		elif cooking_level < 66:
			$AnimatedSprite2D.visible = true
			$AnimatedSprite2D.play(color + "_mid")
			$TopOutline.hide()
			$MidOutline.show()
			$BottomOutline.hide()
		elif cooking_level < 100:
			$AnimatedSprite2D.play(color + "_low")
			$TopOutline.hide()
			$MidOutline.hide()
			$BottomOutline.show()
		else: 
			$AnimatedSprite2D.play("empty")
			$TopOutline.hide()
			$MidOutline.hide()
			$BottomOutline.hide()
	if len(ingredients) == 0:
		$Ingredient1.visible = false
		$Ingredient2.visible = false
	elif len(ingredients) == 1:
		ingredient_sprites[0].texture = ingredient_textures[ingredients[0]]["full"]
		ingredient_sprites[0].visible = true
		ingredient_sprites[1].visible = false
	else:
		ingredient_sprites[0].texture = ingredient_textures[ingredients[0]]["primary"]
		ingredient_sprites[1].texture = ingredient_textures[ingredients[1]]["secondary"]
		ingredient_sprites[0].visible = true
		ingredient_sprites[1].visible = true

func start_cooking():
	if not is_cooking and color != "empty":
		is_cooking = true
		$CookingBar.show()
		timer.start()
		
func stop_cooking():
	if is_cooking:
		is_cooking = false
		$CookingBar.hide()
		timer.stop()

func pause_cooking():
	if is_cooking:
		timer.paused = true

func unpause_cooking():
	if is_cooking:
		timer.paused = true


func _on_timer_timeout():
	cooking_level += 1
	$CookingBar.value = cooking_level
	if cooking_level < 100:
		update_potion_animation()
	else:
		set_color("empty")
		cooking_level = 0
		timer.stop()
		is_cooking = false
		$CookingBar.value = 0
		$CookingBar.hide()
		
func set_color(new_color : String):
	if new_color in available_colors:
		color = new_color
		if color == "empty":
			$TopOutline.hide()
			$MidOutline.hide()
			$BottomOutline.hide()
		else:
			$TopOutline.show()
		update_potion_animation()
		
func add_ingredients(new_ingredient : String):
	if new_ingredient in available_ingredients and len(ingredients) < 2 :
		if new_ingredient in ingredients:
			return
		ingredients.append(new_ingredient)
		update_potion_animation()

func _ready() -> void:
	# Connect signals
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	input_event.connect(_on_input_event)

	add_child(sprite)

	default_collider = CollisionShape2D.new()
	default_collider.shape = RectangleShape2D.new()

	add_child(default_collider)
	if has_custom_collider():
		toggle_default_collider(false)

	ingredient_sprites = [$Ingredient1, $Ingredient2]
	update_potion_animation()


func _process(_delta) -> void:
	# If the input_method is down and the object is and can be grabbed, update it's position
	if Input.is_mouse_button_pressed(input_method) and is_grabbed and grabbable:
		global_position = get_global_mouse_position() + grabbed_offset
		Global.is_dragging_potion = true
		Global.dragged_potion = self
		z_index = 2
		mb_pressed = true
		stop_cooking()
	# Otherwise, if the mouse button was pressed on the previous frame but now isn't, the object is released
	if not Input.is_mouse_button_pressed(input_method) and mb_pressed:
		Global.is_dragging_potion = false
		Global.dragged_potion = null
		z_index = 1
		if Global.hovered_spot:
			global_position = Global.hovered_spot.global_position
			Global.hovered_spot.emit_signal("received_potion", self)
			current_spot = Global.hovered_spot
		elif current_spot:
			global_position = current_spot.global_position
			current_spot.emit_signal("received_potion", self)
		mb_pressed = false

## Returns true if the sprite has a custom collider
func has_custom_collider() -> bool:
	var children = get_children()
	children.erase(default_collider)
	for child in children:
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return true
	
	return false


## Shortcut to toggle on or off the default collider functionality
func toggle_default_collider(on: bool) -> void:
	default_collider.visible = on
	default_collider.disabled = not on


func _on_input_event(_viewport, event, _shape_idx) -> void:
	# Detect when mouse button is clicked inside the area2d
	if event is InputEventMouseButton and grabbable:
		is_grabbed = event.is_pressed()
		# Helps a bit to make the dragging less choppy
		if !centerDrag:
			grabbed_offset = global_position - get_global_mouse_position()

func _on_child_entered_tree(child) -> void:
	if (child is CollisionShape2D or child is CollisionPolygon2D) and child != default_collider:
		toggle_default_collider(false)


func _on_child_exiting_tree(child) -> void:
	if (child is CollisionShape2D or child is CollisionPolygon2D) and child != default_collider:
		toggle_default_collider(true)
