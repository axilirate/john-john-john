class_name CharacterController extends CharacterBody2D

@export var animation_tree: AnimationTree


var speed: float = 30.0




func _process(_delta: float) -> void:
	process_animation_tree()
	process_velocity()
	move_and_slide()





func process_velocity() -> void:
	var horizontal_input: int = get_horizontal_input()
	velocity.x = horizontal_input * speed



func process_animation_tree() -> void:
	if not is_instance_valid(animation_tree):
		return






func get_horizontal_input() -> int:
	return 0
