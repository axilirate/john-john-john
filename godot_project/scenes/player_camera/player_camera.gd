class_name PlayerCamera extends Camera2D


@onready var target_pos: Vector2 = player.global_position
@export var player: Player







func _physics_process(delta: float) -> void:
	target_pos = lerp(target_pos, player.global_position + Vector2(0, -25), delta * 10)
	global_position = target_pos
