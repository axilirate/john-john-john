class_name SkillBook extends Area2D


@export var skill_resource: SkillResource



func _ready() -> void:
	if D.collected_things.has(self.name):
		hide()
		queue_free()
		return
	
	if not is_instance_valid(skill_resource):
		return
	
	modulate = skill_resource.color



func learn() -> void:
	D.active_skills.push_back(skill_resource)
	hide()
	queue_free()
