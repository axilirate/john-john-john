class_name SkillNode extends Node2D

@export var hover_area: Area2D

@export var border_sprite: Sprite2D
@export var hover_sprite: Sprite2D


@export var dependency: SkillNode

var unlocked: bool = false


func _ready() -> void:
	hover_sprite.hide()

func _on_hover_area_mouse_entered() -> void:
	E.skill_node_mouse_entered.emit(self)
	hover_sprite.show()

func _on_hover_area_mouse_exited() -> void:
	E.skill_node_mouse_exited.emit(self)
	hover_sprite.hide()
