@tool
class_name SkillTree extends Node2D

@export var skill_connection_line_holder: Node2D
@export var skill_node_holder: Node2D

var skill_connection_line_scene: PackedScene = preload("res://scenes/skill_connection_line/skill_connection_line.tscn")
var skill_connection_lines: Dictionary[SkillNode, SkillConnectionLine] = {}


func _ready() -> void:
	E.extraction_animation_finished.connect(func(): update())
	E.skill_node_unlocked.connect(func(): update())
	update()



func update() -> void:
	for child in skill_node_holder.get_children():
		var skill_node: SkillNode
		if child is SkillNode:
			skill_node = child as SkillNode
		
		var is_visible: bool = true
		
		if skill_node.cost == -1:
			if D.active_skills.has(skill_node.resource) and not D.unlocked_skill_nodes.has(skill_node.name):
				D.unlock_skill_node(skill_node)
			is_visible =  D.active_skills.has(skill_node.resource)
		
		skill_node.visible = is_visible
		
		
		if is_instance_valid(skill_node.dependency):
			if not D.unlocked_skill_nodes.has(skill_node.dependency.name):
				skill_node.hide()
				continue
			
			if not skill_connection_lines.has(skill_node):
				skill_connection_lines[skill_node] = skill_connection_line_scene.instantiate()
				skill_connection_line_holder.add_child(skill_connection_lines[skill_node])
				skill_connection_lines[skill_node].add_point(skill_node.dependency.global_position)
				skill_connection_lines[skill_node].add_point(skill_node.global_position)
