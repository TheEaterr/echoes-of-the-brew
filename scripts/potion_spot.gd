class_name PotionSpot
extends Area2D

# Called by an emit_signal in DraggableSprite2D
@warning_ignore("unused_signal")
signal received_potion
@warning_ignore("unused_signal")
signal received_potion_for_client
@warning_ignore("unused_signal")
signal received_potion_for_cooking

var current_potion: Potion = null
var is_client = false
@export var is_cooking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_potion = get_node_or_null("Potion")
	if current_potion:
		current_potion.current_spot = self
		current_potion.global_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

func _on_received_potion(potion:Potion) -> void:
	if is_cooking:
		potion.start_cooking()
	$Sprite2D.material.set_shader_parameter("outline_width", 0.0)
	if current_potion == potion:
		return
	if current_potion:
		current_potion.global_position = potion.current_spot.global_position
		current_potion.current_spot = potion.current_spot
		potion.current_spot.current_potion = current_potion
	else:
		potion.current_spot.current_potion = null
	current_potion = potion
	if is_client:
		emit_signal("received_potion_for_client", potion)


func _on_mouse_entered() -> void:
	$Sprite2D.material.set_shader_parameter("outline_width", 2.0)
	Global.hovered_spot = self


func _on_mouse_exited() -> void:
	$Sprite2D.material.set_shader_parameter("outline_width", 0.0)
	if Global.hovered_spot == self:
		Global.hovered_spot = null
