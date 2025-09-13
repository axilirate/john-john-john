@tool
class_name WorldPopup extends Node2D

@export_group("Nodes") 
@export var label: Label

@export_group("") 
@export_multiline var text: String = ""
@export var area: Area2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	update()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update()
		return
	
	
	hide()
	for body in area.get_overlapping_bodies():
		if body is Player:
			show()
			return


func update() -> void:
	label.text = text
