@tool
class_name SkillTree extends Node2D

@export var skill_connection_line_holder: Node2D
@export var skill_node_holder: Node2D

var skill_connection_line_scene: PackedScene = preload("res://scenes/skill_connection_line/skill_connection_line.tscn")
var skill_connection_lines: Dictionary[SkillNode, SkillConnectionLine] = {}


func _ready() -> void:
	update()



func update() -> void:
	for child in skill_node_holder.get_children():
		var skill_node: SkillNode
		if child is SkillNode:
			skill_node = child as SkillNode
		
		if not is_instance_valid(skill_node.dependency):
			continue
		
		if not skill_connection_lines.has(skill_node):
			skill_connection_lines[skill_node] = skill_connection_line_scene.instantiate()
			skill_connection_line_holder.add_child(skill_connection_lines[skill_node])
			skill_connection_lines[skill_node].add_point(skill_node.dependency.global_position)
			skill_connection_lines[skill_node].add_point(skill_node.global_position)
