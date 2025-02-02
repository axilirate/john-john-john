class_name World extends Node2D

@export var pixel_viewport: SubViewport
@export var pixel_camera: Camera2D

static var player: Player = null





func _ready() -> void:
	get_viewport().set_canvas_cull_mask_bit(1, false)
	pixel_viewport.world_2d = get_world_2d()
	player = $Player



func _process(delta: float) -> void:
	pixel_camera.global_position = player.camera.global_position
	pixel_viewport.size_2d_override = get_viewport().size / 4
