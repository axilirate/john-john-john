class_name PickupProecssor extends Node


@export var player: Player

var held_item: PickableItem = null




func _ready() -> void:
	player.item_picked_up.connect(_on_item_picked_up)



func _on_item_picked_up(item: PickableItem):
	held_item = item



func _physics_process(delta: float) -> void:
	if held_item == null:
		return
	
	var target_pos: Vector2 = player.pickable_target_marker.global_position
	var speed: float = held_item.global_position.distance_to(target_pos) * 7
	held_item.velocity = held_item.global_position.direction_to(target_pos) * speed
	
	held_item.move_and_slide()
