class_name World extends Node2D

static var player: Player = preload("res://scenes/player/player.tscn").instantiate()

@export var player_spawn: Marker2D



func _ready() -> void:
	player_spawn.add_child(player)
