class_name SkillTreeContainer extends SubViewportContainer






func _ready() -> void:
	hide()
	E.extraction_animation_finished.connect(func():
		show()
		)
