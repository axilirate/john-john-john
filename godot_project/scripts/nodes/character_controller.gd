class_name CharacterController extends CharacterBody2D




const TIME_TO_MAX_HEIGHT: float = 0.3
const DEFAULT_SPEED: float = 45
const MAX_HEIGHT: float = 21




var jump_force: float = calculate_jump_force()
var gravity: float = calculate_gravity()


var speed: float = DEFAULT_SPEED




func _physics_process(delta: float) -> void:
	_process_velocity(delta)






func _process_velocity(delta: float) -> void:
	_process_gravity(delta)
	_process_movement()
	_process_jump()
	
	move_and_slide()




func _process_movement() -> void:
	velocity.x = get_horizontal_input() * speed



func _process_jump() -> void:
	if not is_on_floor():
		return
	
	if not Input.is_action_just_pressed("jump"):
		return
	
	velocity.y = -jump_force



func _process_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
		return 
	
	velocity.y += gravity * delta




func get_horizontal_input() -> int:
	if Input.is_action_pressed("move_right"):
		return 1
	
	if Input.is_action_pressed("move_left"):
		return -1
	
	return 0



func calculate_gravity():
	return (2 * MAX_HEIGHT) / pow(TIME_TO_MAX_HEIGHT, 2)

func calculate_jump_force():
	return (2 * MAX_HEIGHT) / (TIME_TO_MAX_HEIGHT)
