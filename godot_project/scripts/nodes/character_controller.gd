class_name CharacterController extends CharacterBody2D

@export var animation_tree: AnimationTree
@export var sprite: Sprite2D

var last_input: Vector2 = get_input()
var speed: float = 35.0



func _process(_delta: float) -> void:
	process_last_input.call_deferred()
	process_animation_tree()
	process_velocity()
	move_and_slide()
	process_sprite()



func process_last_input() -> void:
	last_input = get_input()



func process_velocity() -> void:
	process_horizontal_movement()
	process_gravity()
	process_jump()




func process_gravity() -> void:
	velocity.y += World.gravity
	
	if is_on_floor():
		velocity.y = 0



func process_jump() -> void:
	var input: Vector2 = get_input()
	
	if is_on_floor() and just_pressed_jump():
		velocity.y -= 200
	
	if velocity.y < 0 and just_released_jump():
		velocity.y = 0



func process_horizontal_movement() -> void:
	var input: Vector2 = get_input()
	velocity.x = input.x * speed


func process_sprite() -> void:
	pass


func process_animation_tree() -> void:
	if not is_instance_valid(animation_tree):
		return


func just_pressed_jump() -> bool:
	return last_input.y <= 0 and get_input().y > 0

func just_released_jump() -> bool:
	return last_input.y > 0 and get_input().y <= 0


func get_input() -> Vector2:
	return Vector2.ZERO
