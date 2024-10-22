class_name PotionSpot
extends Area2D

# Called by an emit_signal in DraggableSprite2D
@warning_ignore("unused_signal")
signal received_potion

var hovering_potion: DraggablePotion = null
var current_potion: DraggablePotion = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

func _on_area_entered(area:Area2D) -> void:
	if area is DraggablePotion and (current_potion != hovering_potion or current_potion == null) and area.is_grabbed:
		hovering_potion = area
		$SpotRect.color = Color(0, 1, 0, 1)


func _on_area_exited(area:Area2D) -> void:
	if area == hovering_potion:
		hovering_potion = null
		$SpotRect.color = Color(1, 1, 1, 1)
	if area == current_potion:
		current_potion = null

func _on_received_potion(potion:DraggablePotion) -> void:
	$SpotRect.color = Color(1, 1, 1, 1)
	if current_potion == potion:
		return
	hovering_potion = null
	if current_potion:
		current_potion.position = potion.source_area.position
		potion.source_area.emit_signal("received_potion", current_potion)
	current_potion = potion
