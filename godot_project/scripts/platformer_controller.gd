class_name PlatformerController2D
extends CharacterBody2D

## SIGNALS
signal jumped(is_ground_jump: bool)
signal hit_ground()
signal dashed()

# Set these to the name of your action (in the Input Map)
@export var input_left : String = "move_left"
@export var input_right : String = "move_right"
@export var input_jump : String = "jump"

## -----------------------------
## DASH PROPERTIES & STATE
## -----------------------------
@export var input_dash: String = "dash"
@export var dash_speed: float = 275
@export var dash_duration: float = 0.1
@export var dash_cooldown: float = 0.0
@export var dash_in_air: bool = true
@export var dash_stops_vertical_velocity: bool = true

var is_dashing: bool = false
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0

# Tracks if we've already dashed before landing again.
var has_dashed: bool = false

## -----------------------------
## JUMP / PLATFORMER PROPERTIES
## -----------------------------
const DEFAULT_MAX_JUMP_HEIGHT = 30
const DEFAULT_MIN_JUMP_HEIGHT = 15
const DEFAULT_DOUBLE_JUMP_HEIGHT = 100
const DEFAULT_JUMP_DURATION = 0.3

var _max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT
@export var max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT:
	get:
		return _max_jump_height
	set(value):
		_max_jump_height = value
		default_gravity = calculate_gravity(_max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(_max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
			jump_velocity, min_jump_height, default_gravity
		)

var _min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT
@export var min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT:
	get:
		return _min_jump_height
	set(value):
		_min_jump_height = value
		release_gravity_multiplier = calculate_release_gravity_multiplier(
			jump_velocity, min_jump_height, default_gravity
		)

var _double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT
@export var double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT:
	get:
		return _double_jump_height
	set(value):
		_double_jump_height = value
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)

var _jump_duration: float = DEFAULT_JUMP_DURATION
@export var jump_duration: float = DEFAULT_JUMP_DURATION:
	get:
		return _jump_duration
	set(value):
		_jump_duration = value
		default_gravity = calculate_gravity(max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
			jump_velocity, min_jump_height, default_gravity
		)

@export var falling_gravity_multiplier = 1.5
@export var max_jump_amount = 0
@export var max_acceleration = 2500
@export var friction = 80
@export var can_hold_jump : bool = false
@export var coyote_time : float = 0.1
@export var jump_buffer : float = 0.1

var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
var release_gravity_multiplier : float

var jumps_left : int
var holding_jump := false

enum JumpType { NONE, GROUND, AIR }
var current_jump_type: JumpType = JumpType.NONE

var _was_on_ground: bool
var acc = Vector2()

@onready var is_coyote_time_enabled = coyote_time > 0
@onready var is_jump_buffer_enabled = jump_buffer > 0
@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()

func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity
	)

func _ready():
	if is_coyote_time_enabled:
		add_child(coyote_timer)
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true
	
	if is_jump_buffer_enabled:
		add_child(jump_buffer_timer)
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true

## -----------------------------------------------------
## INPUT
## -----------------------------------------------------
func _input(event):
	# Reset horizontal acceleration each frame
	acc.x = 0

	if Input.is_action_pressed(input_left):
		acc.x = -max_acceleration
	
	if Input.is_action_pressed(input_right):
		acc.x = max_acceleration
	
	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		start_jump_buffer_timer()
		if (not can_hold_jump and can_ground_jump()) or can_double_jump():
			jump()
	
	if Input.is_action_just_released(input_jump):
		holding_jump = false

	# ----------------
	# DASH INPUT
	# ----------------
	if Input.is_action_just_pressed(input_dash):
		if can_perform_dash():
			var dash_dir = 0.0
			if Input.is_action_pressed(input_right):
				dash_dir = 1.0
			elif Input.is_action_pressed(input_left):
				dash_dir = -1.0
			start_dash(dash_dir)

## -----------------------------------------------------
## PHYSICS PROCESS
## -----------------------------------------------------
func _physics_process(delta):
	# Count down dash cooldown if it's active
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta
		if dash_cooldown_left < 0:
			dash_cooldown_left = 0

	# If currently dashing, override normal movement/physics
	if is_dashing:
		dash_time_left -= delta
		if dash_time_left <= 0:
			is_dashing = false
			dash_cooldown_left = dash_cooldown
			if is_jump_buffer_timer_running() and is_feet_on_ground():
				jump()
		
		move_and_slide()
		_was_on_ground = is_feet_on_ground()
		return

	# Normal movement if not dashing
	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
	
	if is_feet_on_ground():
		has_dashed = false
	
	# Check if we just hit the ground
	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		# Reset 'has_dashed' now that we're on the ground

		if is_jump_buffer_timer_running() and not can_hold_jump:
			jump()

		hit_ground.emit()

	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump:
			jump()

	# Apply gravity + friction
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity

	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta

	_was_on_ground = is_feet_on_ground()
	move_and_slide()

## -----------------------------------------------------
## DASH HELPER FUNCTIONS
## -----------------------------------------------------
func can_perform_dash() -> bool:
	# If dash is on cooldown, we cannot dash
	if dash_cooldown_left > 0:
		return false

	# If we already dashed (has_dashed == true), can't dash again
	if has_dashed:
		return false
	
	# If we do not allow dashing in the air, check jump type
	if not dash_in_air and current_jump_type != JumpType.NONE:
		return false
	
	return true

func start_dash(direction: float):
	# Already dashing? Bail out.
	if is_dashing:
		return

	is_dashing = true
	dash_time_left = dash_duration
	has_dashed = true  # Mark that we've dashed this jump

	if dash_stops_vertical_velocity:
		velocity.y = 0

	# If no direction is pressed, dash in the direction of current velocity.x
	if direction == 0:
		direction = sign(velocity.x)
		if direction == 0:
			# If we still have no direction, cancel the dash
			is_dashing = false
			has_dashed = false
			return

	velocity.x = dash_speed * sign(direction)

	emit_signal("dashed")

## -----------------------------------------------------
## STANDARD PLATFORMER/JUMP HELPER FUNCTIONS
## -----------------------------------------------------
func start_coyote_timer():
	if is_coyote_time_enabled:
		coyote_timer.start()

func start_jump_buffer_timer():
	if is_jump_buffer_enabled:
		jump_buffer_timer.start()

func is_coyote_timer_running():
	if is_coyote_time_enabled and not coyote_timer.is_stopped():
		return true
	return false

func is_jump_buffer_timer_running():
	if is_jump_buffer_enabled and not jump_buffer_timer.is_stopped():
		return true
	return false

func can_ground_jump() -> bool:
	# Prevent jumping if currently dashing
	if is_dashing:
		return false

	if jumps_left > 0 and current_jump_type == JumpType.NONE:
		return true
	elif is_coyote_timer_running():
		return true
	return false

func can_double_jump() -> bool:
	if jumps_left <= 1 and jumps_left == max_jump_amount:
		return false
	if jumps_left > 0 and not is_feet_on_ground() and coyote_timer.is_stopped():
		return true
	return false

func is_feet_on_ground() -> bool:
	if is_on_floor() and default_gravity >= 0:
		return true
	if is_on_ceiling() and default_gravity <= 0:
		return true
	return false

func jump():
	if can_double_jump():
		double_jump()
	else:
		ground_jump()

func double_jump():
	if jumps_left == max_jump_amount:
		jumps_left -= 1
	velocity.y = -double_jump_velocity
	current_jump_type = JumpType.AIR
	jumps_left -= 1
	jumped.emit(false)

func ground_jump():
	velocity.y = -jump_velocity
	current_jump_type = JumpType.GROUND
	jumps_left -= 1
	coyote_timer.stop()
	jumped.emit(true)

func apply_gravity_multipliers_to(gravity: float) -> float:
	# If we are falling
	if velocity.y * sign(default_gravity) > 0:
		gravity *= falling_gravity_multiplier
	# If we're rising but jump was released (and not a double jump)
	elif velocity.y * sign(default_gravity) < 0:
		if not holding_jump:
			# Always jump to max height when we are using a double jump
			if not current_jump_type == JumpType.AIR:
				gravity *= release_gravity_multiplier
	return gravity

func calculate_gravity(p_max_jump_height: float, p_jump_duration: float) -> float:
	return (2 * p_max_jump_height) / pow(p_jump_duration, 2)

func calculate_jump_velocity(p_max_jump_height: float, p_jump_duration: float) -> float:
	return (2 * p_max_jump_height) / p_jump_duration

func calculate_jump_velocity2(p_max_jump_height: float, p_gravity: float) -> float:
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)

func calculate_release_gravity_multiplier(
		p_jump_velocity: float,
		p_min_jump_height: float,
		p_gravity: float
	) -> float:
	var release_gravity = pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity

func calculate_friction(time_to_max: float) -> float:
	return 1 - (2.30259 / time_to_max)

func calculate_speed(p_max_speed: float, p_friction: float) -> float:
	return (p_max_speed / p_friction) - p_max_speed
