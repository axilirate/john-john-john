class_name SkillNode extends Node2D

@export var hover_area: Area2D

@export var border_sprite: Sprite2D
@export var hover_sprite: Sprite2D
@export var icon_sprite: Sprite2D

@export var resource: SkillResource
@export var dependency: SkillNode
@export var cost: int

var hovering: bool = false


func _ready() -> void:
	if is_instance_valid(resource):
		icon_sprite.texture = resource.icon
	hover_sprite.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pass



func _on_hover_area_mouse_entered() -> void:
	E.skill_node_mouse_entered.emit(self)
	hover_sprite.show()
	hovering = true


func _on_hover_area_mouse_exited() -> void:
	E.skill_node_mouse_exited.emit(self)
	hover_sprite.hide()
	hovering = false
