class_name World extends Node2D

static var gravity: float = 7.5
@export var enemies: Node2D
@export var player: Player




func _ready() -> void:
	for child in enemies.get_children():
		if child is Enemy:
			child.player = player
