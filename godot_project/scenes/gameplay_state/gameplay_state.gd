class_name GameplayState extends Node

const WORLD_SCENE: PackedScene = preload("res://scenes/world/world.tscn")
@export var world: World



func _ready() -> void:
	E.confirmed_upgrades_animation_finished.connect(restart_world)
	E.skill_node_pressed.connect(_on_skill_node_pressed)
	
	E.player_died.connect(func():
		await get_tree().create_timer(1.5).timeout
		restart_world()
		)



func _on_skill_node_pressed(skill_node: SkillNode) -> void:
	if can_unlock(skill_node):
		unlock_skill(skill_node)


func restart_world() -> void:
	remove_child(world)
	world.queue_free()
	
	D.reset_collected_coins()
	D.reset_energy()
	
	world = WORLD_SCENE.instantiate()
	add_child(world)
	move_child(world, 0)



func unlock_skill(skill_node: SkillNode) -> void:
	D.change_extracted_coins(-skill_node.cost)
	D.unlock_skill_node(skill_node)


func can_unlock(skill_node: SkillNode) -> bool:
	return skill_node.cost <= D.extracted_coins
