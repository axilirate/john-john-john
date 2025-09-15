class_name GameplayState extends Node

@export var world: World
var world_scene: PackedScene = preload("res://scenes/world/world.tscn")


func _ready() -> void:
	E.skill_node_pressed.connect(_on_skill_node_pressed)
	E.confirmed_upgrades_animation_finished.connect(func():
		remove_child(world)
		world.queue_free()
		
		world = world_scene.instantiate()
		add_child(world)
		move_child(world, 0)
		)



func _on_skill_node_pressed(skill_node: SkillNode) -> void:
	if can_unlock(skill_node):
		unlock_skill(skill_node)


func unlock_skill(skill_node: SkillNode) -> void:
	D.change_extracted_coins(-skill_node.cost)
	D.unlock_skill_node(skill_node)


func can_unlock(skill_node: SkillNode) -> bool:
	return skill_node.cost <= D.extracted_coins
