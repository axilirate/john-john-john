class_name Player extends CharacterController


@onready var animation_tree: AnimationTree = %AnimationTree

@export_category("Nodes")
@export var sprite: Sprite2D


var flipped: bool = false





func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_process_animation_blends()
	_process_look_dir()
	_process_sprite()




func _process_look_dir() -> void:
	if velocity.x > 0.0:
		flipped = false
	
	if velocity.x < 0.0:
		flipped = true
	
	
	if is_on_wall() and air_time[0] > 0.1:
		var normal: Vector2 = get_wall_normal()
		flipped = normal.x == -1




func _process_sprite() -> void:
	sprite.global_position = global_position + Vector2(0.0, -3.5)
	
	if is_on_floor():
		sprite.global_position.y = round(sprite.global_position.y) + 0.5
	
	if is_equal_approx(velocity.x, 0.0):
		sprite.global_position.x = round(sprite.global_position.x)
	
	sprite.flip_h = flipped
	sprite.offset.x = 0




func _process_animation_blends() -> void:
	var is_running: bool = not is_equal_approx(velocity.x, 0.0) and not get_horizontal_input() == 0
	
	if not animation_tree["parameters/air_jump_one_shot/active"]:
		animation_tree["parameters/air_jump_blend/blend_amount"] = int(flipped)
	
	animation_tree["parameters/air_blend/blend_amount"] = int(not is_on_floor())
	animation_tree["parameters/run_blend/blend_amount"] = int(is_running)


func _on_jumped(jump_type: CharacterController.JumpType) -> void:
	match jump_type:
		CharacterController.JumpType.AIR: animation_tree["parameters/air_jump_one_shot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
