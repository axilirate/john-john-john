class_name CharacterController extends CharacterBody2D

enum State {
	HARD_FALL
	}

@export var animation_tree: AnimationTree
@export var sprite: Sprite2D

var last_input: Vector2 = get_input()
var jump_power: float = 175.0
var speed: float = 35.0

var air_time: float = 0.0

var states: Array[State] = []



func _process(delta: float) -> void:
	process_last_input.call_deferred()
	process_air_time(delta)
	process_hard_fall()
	
	process_velocity(delta)
	process_visuals()
	
	move_and_slide()



func add_state(state: State) -> void:
	if states.has(state):
		return
	states.push_back(state)


func process_last_input() -> void:
	last_input = get_input()


func process_air_time(delta) -> void:
	if is_on_floor():
		air_time = 0.0
		return
	
	air_time += delta



func process_hard_fall() -> void:
	if is_on_floor():
		states.erase(State.HARD_FALL)
	
	if velocity.y < 0 and just_released_jump():
		add_state(State.HARD_FALL)



func process_visuals() -> void:
	process_animation_tree()
	process_sprite()


func process_velocity(delta) -> void:
	process_horizontal_movement()
	process_gravity()
	process_jump(delta)




func process_gravity() -> void:
	velocity.y += World.gravity
	
	if is_on_floor():
		velocity.y = 0



func process_jump(delta) -> void:
	var input: Vector2 = get_input()
	
	if is_on_floor() and just_pressed_jump():
		velocity.y -= jump_power
	
	if not is_equal_approx(velocity.y, 0.0):
		if velocity.y < 0 and states.has(State.HARD_FALL):
			velocity.y = lerp(velocity.y, 0.0, delta * 25)



func process_horizontal_movement() -> void:
	var input: Vector2 = get_input()
	velocity.x = input.x * speed



func process_sprite() -> void:
	var flipped: bool = sprite.flip_h
	
	if velocity.x > 0.0:
		flipped = false
	
	if velocity.x < 0.0:
		flipped = true
	
	#if is_on_wall() and air_time.current > 0.1:
		#var normal: Vector2 = get_wall_normal()
		#flipped = normal.x == -1
	
	sprite.global_position = global_position + Vector2(0.0, -3.5)
	
	if is_on_floor():
		sprite.global_position.y = round(sprite.global_position.y) + 0.5
	
	if is_equal_approx(velocity.x, 0.0):
		sprite.global_position.x = round(sprite.global_position.x)
	
	sprite.flip_h = flipped
	sprite.offset.x = 0




func process_animation_tree() -> void:
	if not is_instance_valid(animation_tree):
		return
	
	var is_running: bool = not is_equal_approx(velocity.x, 0.0) and not get_input().x == 0
	
	#if not animation_tree["parameters/air_jump_one_shot/active"]:
		#animation_tree["parameters/air_jump_blend/blend_amount"] = int(flipped)
	
	animation_tree["parameters/air_blend/blend_amount"] = int(not is_on_floor())
	animation_tree["parameters/run_blend/blend_amount"] = int(is_running)



func just_pressed_jump() -> bool:
	return last_input.y <= 0 and get_input().y > 0

func just_released_jump() -> bool:
	return last_input.y > 0 and get_input().y <= 0


func get_input() -> Vector2:
	return Vector2.ZERO
