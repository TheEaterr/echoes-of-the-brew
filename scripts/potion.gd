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

var over_area: Area2D = null
var source_area: Area2D = null
var destination_area: Area2D = null


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
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
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
	if not is_cooking and color != "empty":
		is_cooking = true
		timer.start()
		
func stop_cooking():
	if is_cooking:
		is_cooking = false
		timer.stop()

func pause_cooking():
	if is_cooking:
		timer.paused = true

func unpause_cooking():
	if is_cooking:
		timer.paused = true


func _on_timer_timeout():
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

func _ready() -> void:
	# Connect signals
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	input_event.connect(_on_input_event)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

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
		z_index = 2
		mb_pressed = true
		stop_cooking()
	# Otherwise, if the mouse button was pressed on the previous frame but now isn't, the object is released
	if not Input.is_mouse_button_pressed(input_method) and mb_pressed:
		z_index = 1
		if over_area:
			over_area.emit_signal("received_potion", self)
			global_position = over_area.global_position
			source_area = over_area
			over_area = null
		else:
			if source_area:
				global_position = source_area.global_position
				source_area.emit_signal("received_potion", self)
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


func _on_area_entered(area:Area2D) -> void:
	if area is PotionSpot:
		# if source area is null, then the object just got instantiated
		if source_area == null:
			source_area = area
			global_position = area.global_position
			source_area.emit_signal("received_potion", self)
		else:
			over_area = area
		

func _on_area_exited(area:Area2D) -> void:
	if area == over_area:
		over_area = null
