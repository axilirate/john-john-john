class_name GameplayState extends Node


@export var world: World
var world_scene: PackedScene = preload("res://scenes/world/world.tscn")


func _ready() -> void:
	E.confirmed_upgrades_animation_finished.connect(func():
		remove_child(world)
		world.queue_free()
		
		world = world_scene.instantiate()
		add_child(world)
		move_child(world, 0)
		)
