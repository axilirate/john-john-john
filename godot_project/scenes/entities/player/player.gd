class_name Player extends PlatformerController2D


@onready var camera_target_pos: Vector2 = global_position
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var camera: Camera2D
@export var sprite: Sprite2D









func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	sprite.global_position = global_position + Vector2(-5, -9)
	
	if is_on_floor():
		sprite.global_position.y = round(sprite.global_position.y)
	
	if is_equal_approx(velocity.x, 0.0):
		sprite.global_position.x = round(sprite.global_position.x)
	
	
	camera_target_pos = lerp(camera_target_pos, global_position, delta * 10)
	camera.global_position = camera_target_pos
	
	_process_sprite()




func _process_sprite() -> void:
	animation_player.play(get_target_animation())
	
	if velocity.x > 0.0:
		sprite.flip_h = false
		sprite.offset.x = 0
	
	if velocity.x < 0.0:
		sprite.flip_h = true
		sprite.offset.x = 1





func get_target_animation() -> String:
	if not is_on_floor():
		return "air"
	
	if not is_equal_approx(velocity.x, 0.0) and not get_horizontal_input() == 0:
		return "run"
	
	return "idle"




func get_horizontal_input() -> int:
	if Input.is_action_pressed("move_right"):
		return 1
	
	if Input.is_action_pressed("move_left"):
		return -1
	
	return 0
