class_name CharacterController extends CharacterBody2D

@export var animation_tree: AnimationTree


var speed: float = 30.0




func _process(_delta: float) -> void:
	process_animation_tree()
	process_velocity()
	move_and_slide()



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
	if input.y > 0 and is_on_floor():
		velocity.y -= 200



func process_horizontal_movement() -> void:
	var input: Vector2 = get_input()
	velocity.x = input.x * speed



func process_animation_tree() -> void:
	if not is_instance_valid(animation_tree):
		return


func get_input() -> Vector2:
	return Vector2.ZERO
