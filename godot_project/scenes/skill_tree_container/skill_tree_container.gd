class_name SkillTreeContainer extends MarginContainer


@export var confirm_upgrades_button: Button



func _ready() -> void:
	confirm_upgrades_button.pressed.connect(func(): E.confirmed_upgrades.emit())
	E.confirmed_upgrades_animation_finished.connect(func(): hide())
	E.extraction_animation_finished.connect(func(): show())
	
	hide()
