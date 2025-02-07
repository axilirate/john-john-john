class_name Doorway extends Area2D

@export var sprite_right: Sprite2D
@export var sprite_left: Sprite2D


var data: Dictionary = {
	"opened": false
}




func _ready() -> void:
	World.player.door_opened.connect(_on_player_door_opened)
	G.data[self.name] = data




func _on_player_door_opened(door: Doorway) -> void:
	if door == self:
		open()





func open() -> void:
	sprite_right.region_rect.position.x = 16
	sprite_left.region_rect.position.x = 11
	data["opened"] = true
