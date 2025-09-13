class_name ExtractionDoor extends Area2D


@export var wall_sprite_left: Sprite2D
@export var wall_sprite_right: Sprite2D



func _ready() -> void:
	wall_sprite_right.hide()
	wall_sprite_left.hide()


func show_wall(player_pos: Vector2) -> void:
	if global_position.x <= player_pos.x:
		wall_sprite_left.show()
	
	if global_position.x > player_pos.x:
		wall_sprite_right.show()
