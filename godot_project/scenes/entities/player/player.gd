class_name Player extends CharacterBody2D



@onready var camera_target_pos: Vector2 = global_position
@onready var animation_player: AnimationPlayer = %AnimationPlayer


@export_category("Nodes")
@export var camera: Camera2D
@export var sprite: Sprite2D




var jump_force: float = 125
var friction: float = 5
var gravity: float = 5
var speed: float = 5


var jump_duration: float = 1
var jump_height: float = 1


var force: Vector2 = Vector2.ZERO






func _physics_process(delta: float) -> void:
	_process_velocity(delta)
	_process_camera(delta)
	_process_sprite()





func _process_velocity(delta: float) -> void:
	force.y += gravity
	
	
	if is_on_floor():
		force.y = -force.y * 0.5
		
		if abs(force.y) < gravity + 45:
			force.y = 0
		
		if Input.is_action_just_pressed("jump"):
			force.y = -jump_force
	
	
	if is_on_wall():
		force.x = -force.x
	
	

	
	
	force.x += get_horizontal_input() * speed
	
	force.x = lerp(force.x, 0.0, delta * friction)
	
	
	velocity = force
	move_and_slide()





func _process_camera(delta: float) -> void:
	camera_target_pos = lerp(camera_target_pos, global_position + Vector2(0, -25), delta * 10)
	camera.global_position = camera_target_pos





func _process_sprite() -> void:
	animation_player.play(get_target_animation())
	
	sprite.global_position = global_position + Vector2(-5, -9)
	
	if is_on_floor():
		sprite.global_position.y = round(sprite.global_position.y)
	
	if is_equal_approx(force.x, 0.0):
		sprite.global_position.x = round(sprite.global_position.x)
	
	if force.x > 0.0:
		sprite.flip_h = false
		sprite.offset.x = 0
	
	if force.x < 0.0:
		sprite.flip_h = true
		sprite.offset.x = 1







func get_target_animation() -> String:
	if not is_on_ground():
		return "air"
	
	if not is_equal_approx(force.x, 0.0) and not get_horizontal_input() == 0:
		return "run"
	
	return "idle"




func is_on_ground() -> bool:
	return is_on_floor() and is_equal_approx(force.y, 0.0)




func get_horizontal_input() -> int:
	if Input.is_action_pressed("move_right"):
		return 1
	
	if Input.is_action_pressed("move_left"):
		return -1
	
	return 0
