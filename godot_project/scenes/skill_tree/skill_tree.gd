@tool
class_name SkillTree extends Node2D




func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	for child in get_children():
		var skill_node: SkillNode
		if child is SkillNode:
			skill_node = child as SkillNode
		
		if is_instance_valid(skill_node.dependency):
			pass
