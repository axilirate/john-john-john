@tool
class_name SkillTree extends Node2D

@export var skill_connection_line_holder: Node2D
@export var skill_node_holder: Node2D

var skill_connection_line_scene: PackedScene = preload("res://scenes/skill_connection_line/skill_connection_line.tscn")
var skill_connection_lines: Dictionary[SkillNode, SkillConnectionLine] = {}


func _ready() -> void:
	E.extraction_animation_finished.connect(func(): update())
	E.skill_node_unlocked.connect(func(): update())
	E.skill_node_locked.connect(func(): update())
	update()


func update() -> void:
	for child in skill_node_holder.get_children():
		if child is SkillNode:
			update_skill_node(child)


func update_skill_node(skill_node: SkillNode) -> void:
	for child in skill_node.get_children():
		if child is SkillNode:
			update_skill_node(child)
	
	skill_node.show()
	
	if skill_node.get_parent() is SkillNode:
		if not D.unlocked_skill_nodes.has(skill_node.get_parent().name):
			if skill_connection_lines.has(skill_node):
				skill_connection_lines[skill_node].queue_free()
				skill_connection_lines.erase(skill_node)
			skill_node.hide()
			return
		
		if not skill_connection_lines.has(skill_node):
			skill_connection_lines[skill_node] = skill_connection_line_scene.instantiate()
			skill_connection_line_holder.add_child(skill_connection_lines[skill_node])
			skill_connection_lines[skill_node].add_point(skill_node.get_parent().global_position)
			skill_connection_lines[skill_node].add_point(skill_node.global_position)
