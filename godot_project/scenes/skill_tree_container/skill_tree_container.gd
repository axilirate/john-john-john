class_name SkillTreeContainer extends MarginContainer


@export var confirm_upgrades_button: Button
@export var skill_points_label: CustomLabel


func _ready() -> void:
	confirm_upgrades_button.pressed.connect(func(): E.confirmed_upgrades.emit())
	E.confirmed_upgrades_animation_finished.connect(func(): hide())
	E.extraction_animation_finished.connect(func(): show())
	E.skill_points_changed.connect(func(): 
		skill_points_label.text = "Skill Points: " + str(D.skill_points)
		)
	hide()
