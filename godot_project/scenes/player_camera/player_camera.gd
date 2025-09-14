class_name PlayerCamera extends Camera2D

@onready var target_pos: Vector2 = get_target_pos()
@export var player: Player


func _ready() -> void:
	global_position = target_pos

func _physics_process(delta: float) -> void:
	target_pos = lerp(target_pos, get_target_pos(), delta * 10)
	global_position = target_pos

func get_target_pos() -> Vector2:
	return player.global_position + Vector2(0, -25)
