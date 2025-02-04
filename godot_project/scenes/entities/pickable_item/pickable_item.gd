class_name PickableItem extends CharacterBody2D



var holder: Player = null



func _physics_process(delta: float) -> void:
	if World.player == null:
		return
	
	var target_pos: Vector2 = World.player.pickable_target_marker.global_position
	var speed: float = global_position.distance_to(target_pos) * 7
	velocity = global_position.direction_to(target_pos) * speed
	
	move_and_slide()
