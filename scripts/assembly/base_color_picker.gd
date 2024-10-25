class_name PotionBaseColorPicker
extends Control

@export var base_color: String = "blue"

func _ready() -> void:
	$AnimatedSprite2D.play(base_color)


# Returns the data to pass from an object when you click and drag away from
# this object. Also calls `set_drag_preview()` to show the mouse dragging
# something so the user knows that the operation is working.
func _get_drag_data(_at_position: Vector2) -> String:
	# Use another colorpicker as drag preview.
	var cpb := ColorPickerButton.new()
	if base_color == "blue":
		cpb.color = "yellow"
	else:
		cpb.color = base_color
	cpb.size = Vector2(50.0, 50.0)

	# Allows us to center the color picker on the mouse.
	var preview := Control.new()
	preview.add_child(cpb)
	cpb.position = -0.5 * cpb.size
	cpb.z_index = 2

	# Sets what the user will see they are dragging.
	set_drag_preview(preview)

	# Return color as drag data.
	return base_color


func _on_mouse_entered() -> void:
	if !Global.is_dragging_potion:
		$AnimatedSprite2D.material.set_shader_parameter("outline_width", 4.0)


func _on_mouse_exited() -> void:
	$AnimatedSprite2D.material.set_shader_parameter("outline_width", 0.0)
