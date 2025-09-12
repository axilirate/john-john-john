class_name CharacterController extends CharacterBody2D

@export var animation_tree: AnimationTree





func _process(_delta: float) -> void:
	process_animation_tree()






func process_animation_tree() -> void:
	if not is_instance_valid(animation_tree):
		return
