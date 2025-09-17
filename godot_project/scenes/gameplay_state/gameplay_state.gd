class_name GameplayState extends Node

const WORLD_SCENE: PackedScene = preload("res://scenes/world/world.tscn")
@export var world: World



func _ready() -> void:
	E.confirmed_upgrades_animation_finished.connect(restart_world)
	E.skill_node_pressed.connect(_on_skill_node_pressed)
	
	E.player_died.connect(func(_player: Player):
		await get_tree().create_timer(1.5).timeout
		restart_world()
		)



func _on_skill_node_pressed(skill_node: SkillNode) -> void:
	if D.unlocked_skill_nodes.has(skill_node.name):
		D.lock_skill_node(skill_node)
		return
	
	if can_unlock(skill_node):
		D.unlock_skill_node(skill_node)


func restart_world() -> void:
	remove_child(world)
	world.queue_free()
	
	D.reset_temp_coins()
	D.reset_energy()
	
	world = WORLD_SCENE.instantiate()
	add_child(world)
	move_child(world, 0)




func can_unlock(skill_node: SkillNode) -> bool:
	if D.unlocked_skill_nodes.has(skill_node.name):
		return false
	return skill_node.cost <= D.extracted_coins
