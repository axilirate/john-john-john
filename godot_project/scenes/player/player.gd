class_name Player extends CharacterController








func get_horizontal_input() -> int:
	if Input.is_action_pressed("move_left"):
		return -1
	
	if Input.is_action_pressed("move_right"):
		return 1
	
	return 0
