class_name PotionIngredientPicker
extends Control

@export var ingredient: String = "eyeball"
var available_ingredients = ["bones", "flower", "roots", "eyeball", "gems", "leaves"]
var ingredient_textures = {
	"bones": preload("res://assets/bones.png"),
	"flower": preload("res://assets/flower.png"),
	"roots": preload("res://assets/roots.png"),
	"eyeball": preload("res://assets/eyeball.png"),
	"gems": preload("res://assets/gems.png"),
	"leaves": preload("res://assets/leaves.png")
}


func _ready() -> void:
	$Sprite2D.texture = ingredient_textures[ingredient]
	$Sprite2D2.texture = ingredient_textures[ingredient]
	$Sprite2D3.texture = ingredient_textures[ingredient]


# Returns the data to pass from an object when you click and drag away from
# this object. Also calls `set_drag_preview()` to show the mouse dragging
# something so the user knows that the operation is working.
func _get_drag_data(_at_position: Vector2) -> String:
	# Use another colorpicker as drag preview.
	var sprite2d := Sprite2D.new()
	sprite2d.texture = $Sprite2D.texture
	sprite2d.scale = Vector2(0.3, 0.3)

	# Allows us to center the color picker on the mouse.
	var preview := Control.new()
	preview.add_child(sprite2d)
	# sprite2d.position = -0.5 * sprite2d.size
	sprite2d.z_index = 2

	# Sets what the user will see they are dragging.
	set_drag_preview(preview)

	# Return color as drag data.
	return ingredient

func _on_mouse_entered() -> void:
	if !Global.is_dragging_potion:
		$Sprite2D.material.set_shader_parameter("outline_width", 4.0)
		$Sprite2D2.material.set_shader_parameter("outline_width", 4.0)
		$Sprite2D3.material.set_shader_parameter("outline_width", 4.0)


func _on_mouse_exited() -> void:
	$Sprite2D.material.set_shader_parameter("outline_width", 0.0)
	$Sprite2D2.material.set_shader_parameter("outline_width", 0.0)
	$Sprite2D3.material.set_shader_parameter("outline_width", 0.0)
