class_name Player extends PlatformerController2D


@onready var camera_target_pos: Vector2 = global_position

@export var camera: Camera2D
@export var sprite: Sprite2D



func _process(delta: float) -> void:
	sprite.global_position = global_position.round() + Vector2(-5, -9)
	
	



func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	camera_target_pos = lerp(camera_target_pos, global_position, delta * 5)
	camera.global_position = camera_target_pos.round()
