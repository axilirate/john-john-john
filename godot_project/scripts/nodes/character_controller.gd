class_name CharacterController extends CharacterBody2D

enum JumpType {GROUND, AIR, WALL}

signal jumped(jump_type: JumpType)
signal landed



const CONTROL_RECHARGE_SPEED: float = 3

const TIME_TO_MAX_HEIGHT: float = 0.3
const TIME_TO_LAND: float = 0.2

const DASH_DURATION: float = 0.15
const DASH_COOLDOWN: float = 1.0
const DASH_LENGTH: float = 25

const DEFAULT_SPEED: float = 57
const MAX_HEIGHT: float = 21
const MIN_HEIGHT: float = 7

const WALL_JUMP_FORCE: float = 75



@export var dash_curve: Curve


var jump_strength: float = get_jump_strength()
var jump_gravity: float = get_jump_gravity()
var fall_gravity: float = get_fall_gravity()

#var time_to_min_height: float = get_time_to_min_height()
#var dash_force: float = 0.0
#
#
#var move_force: Vector2 = Vector2.ZERO

#

#
#


#var dash_direction: Vector2 = Vector2.ZERO

#
#var last_input_vector: Vector2 = Vector2.ZERO
#
#var dash_cooldown: float = 0.0
#
#var dash_velocity: Vector2 = Vector2.ZERO
#var gravity_force: float = 0.0


var max_air_jumps: int = 1


var ground_time: ActionDuration = ActionDuration.new()
var wall_time: ActionDuration = ActionDuration.new()
var air_time: ActionDuration = ActionDuration.new()


var movement_force: float = 0.0
var gravity_force: float = 0.0
var jump_force: float = 0.0


var air_jumps_left: float = max_air_jumps
var control: Vector2 = Vector2.ONE
var speed: float = DEFAULT_SPEED
var is_dashing: bool


class ActionDuration:
	var current: float = 0.0
	var stopped: float = 0.0
	var last: float = 0.0




func _ready() -> void:
	pass




func _physics_process(delta: float) -> void:
	_process_ground_time(delta)
	_process_wall_time(delta)
	_process_air_time(delta)
	
	
	_process_movement_force(delta)
	_process_gravity_force(delta)
	_process_jump_force(delta)
	
	velocity = get_target_velocity()
	move_and_slide()






func _process_ground_time(delta: float) -> void:
	ground_time.last = ground_time.current
	
	if is_on_floor():
		ground_time.current += delta
		ground_time.stopped = 0.0
		return
	
	ground_time.stopped += delta
	ground_time.current = 0.0



func _process_wall_time(delta: float) -> void:
	wall_time.last = wall_time.current
	
	if is_on_wall():
		wall_time.current += delta
		wall_time.stopped = 0.0
		return
	
	wall_time.stopped += delta
	wall_time.current = 0.0



func _process_air_time(delta: float) -> void:
	air_time.last = air_time.current
	
	if not is_on_floor():
		air_time.current += delta
		air_time.stopped = 0.0
		return
	
	air_time.stopped += delta
	air_time.current = 0.0






func _process_gravity_force(delta: float) -> void:
	if is_on_floor():
		gravity_force = 0.0
		return
	
	var target_gravity: float = get_target_gravity()
	gravity_force += target_gravity * delta



func _process_jump_force(delta: float) -> void:
	
	if not Input.is_action_pressed("jump"):
		if velocity.y < 0.0 and air_time.current > 0.1:
			jump_force = -get_jump_strength() * 0.5
	
	if not is_on_floor():
		return
	
	jump_force = 0.0
	
	if Input.is_action_pressed("jump"):
		jump_force = -get_jump_strength()




func _process_movement_force(delta: float) -> void:
	var horizontal_input: int = get_horizontal_input()
	movement_force = lerp(movement_force, horizontal_input * speed, delta * 17.5)







func get_target_velocity() -> Vector2:
	var target_velocity: Vector2 = Vector2(movement_force, gravity_force)
	target_velocity.y += jump_force
	
	return target_velocity



func get_target_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func get_horizontal_input() -> int:
	if Input.is_action_pressed("move_right"):
		return 1
	
	if Input.is_action_pressed("move_left"):
		return -1
	
	return 0




func get_jump_gravity():
	return (2 * MAX_HEIGHT) / pow(TIME_TO_MAX_HEIGHT, 2)

func get_fall_gravity():
	return (2 * MAX_HEIGHT) / pow(TIME_TO_LAND, 2)

func get_jump_strength():
	return (2 * MAX_HEIGHT) / (TIME_TO_MAX_HEIGHT)


#func _ready() -> void:
	#dash_force = get_dash_force()
	#landed.connect(_on_landed)
#
#
#func _on_landed() -> void:
	#air_jumps_left = max_air_jumps
#
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		#if input_vector == Vector2.ZERO:
			#return
		#
		#if not is_dashing:
			#dash_direction = input_vector
#
#
#func _physics_process(delta: float) -> void:
	#_process_ground_time(delta)
	#_process_wall_time(delta)
	#_process_air_time(delta)
	#_process_velocity(delta)
	#_process_control(delta)
	#_process_dash(delta)
#
#
#func _process_velocity(delta: float) -> void:
	#velocity = get_target_velocity(delta)
	#_process_gravity(delta)
	#_process_jump()
	#_process_land()
	#
	#move_and_slide()
#
#
#
#func _process_control(delta: float) -> void:
	#control = control.move_toward(Vector2.ONE, CONTROL_RECHARGE_SPEED * delta)
#
#
#
#
#
#
#
#
#
#
#
#
#
#func _process_movement(delta: float) -> void:
	#if ground_time.current > 0.05:
		#return
	#
	#
	#if not horizontal_input == 0:
		#var target_vel: float = horizontal_input * speed
		#
		#if sign(velocity.x) == horizontal_input:
			#target_vel = maxf(abs(target_vel), abs(velocity.x)) * horizontal_input
		#
		#velocity.x = lerp(velocity.x, target_vel, delta * 17.5 * maxf(0.0, control.x))
#
#
#
#
#
#
#
#
#func _process_jump() -> void:
	#var in_air: bool = air_time.current > 0.1
	#
	#if not Input.is_action_just_pressed("jump"):
		#return
	#
	#if in_air:
		#if wall_time.stopped < 0.1:
			#_jump(JumpType.WALL)
			#return
		#
		#if air_jumps_left > 0:
			#_jump(JumpType.AIR)
			#return
		#return
	#
	#_jump(JumpType.GROUND)
#
#
#
#

#
#
#
#
#
#func _process_dash(delta: float) -> void:
	#if not is_dashing:
		#dash_cooldown = maxf(0.0, dash_cooldown - delta)
	#
	#if dash_cooldown > 0.0:
		#return
	#
	#if Input.is_action_pressed("dash"):
		#_dash()
#
#
#
#
#
#func _dash() -> void:
	#var time: float = 0.0
	#dash_cooldown = DASH_COOLDOWN
	#is_dashing = true
	#
	#while true:
		#var value = time / DASH_DURATION
		#dash_velocity = dash_direction * dash_curve.sample_baked(value) * dash_force
		#time += get_physics_process_delta_time()
		#
		#
		#if time > DASH_DURATION:
			#break
		#
		#await get_tree().physics_frame
	#
	#
	#is_dashing = false
#
#
#
#
#
#
#func _process_land() -> void:
	#if air_time.current == 0.0 and air_time.last > 0.0:
		#landed.emit()
#
#
#
#
#func _process_gravity(delta: float) -> void:
	#if is_dashing:
		#return
	#
	#if is_on_floor():
		#gravity_force = 0.0
		#return 
	#
	#var limit: float = jump_force * 1.45
	#var new_gravity: float = get_new_gravity()
	#
	#if velocity.y < 0.0:
		#if Input.is_action_just_released("jump"):
			#gravity_force = 0.0
			#return
	#
	#if is_on_wall() and velocity.y > 0:
		#new_gravity = jump_gravity * 0.5
		#limit = jump_gravity * 0.075
		#if wall_time.current > 0.25:
			#limit = jump_gravity * 0.25
	#
	#gravity_force += new_gravity * delta
	#gravity_force = clampf(gravity_force, -limit, limit)
#
#
#
#
#func get_new_gravity() -> float:
	#return jump_gravity if velocity.y < 0.0 else fall_gravity
#
#
#
#
#
#
#
#
#
#func get_target_velocity(delta: float) -> Vector2:
	#var horizontal_input: int = get_horizontal_input()
	#movement_force = lerp(movement_force, horizontal_input * speed, delta * 17.5)
	#var target_velocity: Vector2 = Vector2(movement_force, gravity_force)
	#
	#if is_dashing:
		#target_velocity += dash_velocity
	#
	#return target_velocity
#
#
#
#
#
#func get_dash_force() -> float:
	#var samples: int = 100
	#var curve_integral: float = 0.0
	## Approximate the integral ∫0^1 f(u) du using sampling
	#for i in range(samples):
		#var u: float = i / float(samples - 1)
		#curve_integral += dash_curve.sample_baked(u)
	#curve_integral /= samples  # This approximates the average value over [0,1]
	#
	## v_base = L / (T * ∫0^1 f(u) du)
	#return DASH_LENGTH / (DASH_DURATION * curve_integral)
#
#
#
#

#
#
#func get_time_to_min_height() -> float:
	#var discriminant = jump_force * jump_force - 2.0 * jump_gravity * MIN_HEIGHT
	#var sqrt_disc = sqrt(discriminant)
	#return (jump_force - sqrt_disc) / jump_gravity
