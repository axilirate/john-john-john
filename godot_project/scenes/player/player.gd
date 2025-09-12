class_name Player extends CharacterController








func get_input() -> Vector2:
	var x: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y: int = int(Input.is_action_pressed("jump"))
	
	return Vector2(x, y)
