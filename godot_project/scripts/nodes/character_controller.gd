class_name CharacterController extends CharacterBody2D

enum JumpType {GROUND, AIR, WALL}

signal jumped(jump_type: JumpType)
signal landed


const CONTROL_RECHARGE_SPEED: float = 3

const TIME_TO_MAX_SPEED: float = 0.1
const TIME_TO_STOP: float = 0.1

const TIME_TO_MAX_HEIGHT: float = 0.3
const DEFAULT_SPEED: float = 57
const MAX_HEIGHT: float = 21
const MIN_HEIGHT: float = 7

const WALL_JUMP_FORCE: float = 75



var jump_force: float = calculate_jump_force()
var gravity: float = calculate_gravity()
var time_to_min_height: float = calculate_time_to_min_height()


var speed: float = DEFAULT_SPEED
var acceleration: float = 0.0
var friction: float = 0.0
var max_air_jumps: int = 1


var wall_time: PackedFloat32Array = [0.0, 0.0]
var air_time: PackedFloat32Array = [0.0, 0.0]
var air_jumps_left: float = max_air_jumps
var control: Vector2 = Vector2.ONE



func _set_speed(new_speed: float) -> void:
	acceleration = speed / TIME_TO_MAX_SPEED
	friction = speed / TIME_TO_STOP
	speed = new_speed



func _ready() -> void:
	landed.connect(_on_landed)
	_set_speed(DEFAULT_SPEED)


func _on_landed() -> void:
	air_jumps_left = max_air_jumps



func _physics_process(delta: float) -> void:
	_process_wall_time(delta)
	_process_air_time(delta)
	_process_velocity(delta)
	_process_control(delta)


func _process_velocity(delta: float) -> void:
	_process_gravity(delta)
	_process_movement(delta)
	_process_jump()
	_process_land()
	
	move_and_slide()



func _process_control(delta: float) -> void:
	control = control.move_toward(Vector2.ONE, CONTROL_RECHARGE_SPEED * delta)



func _process_wall_time(delta: float) -> void:
	wall_time[1] = wall_time[0]
	
	if is_on_wall():
		wall_time[0] += delta
		return
	
	wall_time[0] = 0.0


func _process_air_time(delta: float) -> void:
	air_time[1] = air_time[0]
	
	if not is_on_floor():
		air_time[0] += delta
		return
	
	air_time[0] = 0.0





func _process_movement(delta: float) -> void:
	var horizontal_input: int = get_horizontal_input()
	
	if not horizontal_input == 0:
		var target_speed: float = horizontal_input * acceleration * maxf(control.x, 0.0) * delta
		match horizontal_input:
			1: 
				var remainder: float = speed - velocity.x
				target_speed = minf(target_speed, remainder)
			
			-1: 
				var remainder: float = -velocity.x - speed
				target_speed = maxf(target_speed, remainder)
		
		
		velocity.x += target_speed
		return
	
	
	if air_time[0] == 0.0:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)





func _process_jump() -> void:
	var in_air: bool = air_time[0] > 0.1
	
	if not Input.is_action_just_pressed("jump"):
		return
	
	if in_air:
		if wall_time[0] > 0.1:
			_jump(JumpType.WALL)
			return
		
		if air_jumps_left > 0:
			_jump(JumpType.AIR)
			return
		return
	
	_jump(JumpType.GROUND)




func _jump(jump_type: JumpType) -> void:
	velocity.y = -jump_force
	match jump_type:
		JumpType.AIR: air_jumps_left -= 1
		
		JumpType.WALL:
			var wall_dir: int = get_wall_normal().x
			velocity.x += WALL_JUMP_FORCE * wall_dir
			control.x -= 0.5
	
	jumped.emit(jump_type)







func _process_land() -> void:
	if air_time[0] == 0.0 and air_time[1] > 0.0:
		landed.emit()




func _process_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
		return 
	
	var limit: float = jump_force * 1.45
	var new_gravity: float = gravity
	
	if air_time[0] > time_to_min_height:
		if not Input.is_action_pressed("jump"):
			new_gravity = gravity * 2
	
	if is_on_wall() and velocity.y > 0:
		new_gravity = gravity * 0.5
		limit = gravity * 0.1
	
	velocity.y += new_gravity * delta
	velocity.y = clampf(velocity.y, -limit, limit)







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

func calculate_time_to_min_height() -> float:
	var discriminant = jump_force * jump_force - 2.0 * gravity * MIN_HEIGHT
	var sqrt_disc = sqrt(discriminant)
	return (jump_force - sqrt_disc) / gravity
