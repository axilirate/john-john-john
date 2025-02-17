class_name Player extends CharacterController


@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export_category("Nodes")
@export var sprite: Sprite2D


var flipped: bool = false





func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_process_look_dir()
	
	_process_sprite()




func _process_look_dir() -> void:
	if velocity.x > 0.0:
		flipped = false
	
	if velocity.x < 0.0:
		flipped = true



func _process_sprite() -> void:
	animation_player.play(get_target_animation())
	
	sprite.global_position = global_position + Vector2(-5, -9)
	
	if is_on_floor():
		sprite.global_position.y = round(sprite.global_position.y)
	
	if is_equal_approx(velocity.x, 0.0):
		sprite.global_position.x = round(sprite.global_position.x)
	
	sprite.flip_h = flipped
	sprite.offset.x = 0
	
	if flipped:
		sprite.offset.x = 1






func get_target_animation() -> String:
	if not is_on_floor():
		return "air"
	
	if not is_equal_approx(velocity.x, 0.0) and not get_horizontal_input() == 0:
		return "run"
	
	return "idle"
