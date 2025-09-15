class_name ExtractionDoor extends Area2D


@export var wall_sprite_left: Sprite2D
@export var wall_sprite_right: Sprite2D
@export var door_sprite: Sprite2D
@export var max_extraction: int


func _ready() -> void:
	var region_x: int = 11
	wall_sprite_right.hide()
	wall_sprite_left.hide()
	
	if not can_extract():
		door_sprite.modulate = Color("#5f5f5f")
		region_x = 0
	
	(door_sprite.texture as AtlasTexture).region.position.x = region_x



func show_wall(player_pos: Vector2) -> void:
	if global_position.x <= player_pos.x:
		wall_sprite_left.show()
	
	if global_position.x > player_pos.x:
		wall_sprite_right.show()


func can_extract() -> bool:
	return D.get_extracted_door_coins(self) < max_extraction
