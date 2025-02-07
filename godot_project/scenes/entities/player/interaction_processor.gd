class_name InteractionProcessor extends Node


@export var pickup_processor: PickupProecssor
@export var interaction_area: Area2D
@export var player: Player




func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)




func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not pickup_processor.held_item == null:
		return
	
	if body is PickableItem:
		player.item_picked_up.emit(body)


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Doorway:
		player.door_opened.emit(area)
