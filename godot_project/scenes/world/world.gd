class_name World extends Node2D

static var player_camera: PlayerCamera = preload("res://scenes/player_camera/player_camera.tscn").instantiate()
static var player: Player = preload("res://scenes/player/player.tscn").instantiate()
static var gravity: float = 9.8

@export var player_spawn: Marker2D



func _ready() -> void:
	spawn_player()


func spawn_player() -> void:
	player_spawn.add_child(player)
	player.add_child(player_camera)
