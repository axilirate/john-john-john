class_name Popup2D extends Node2D

@export_group("Nodes")
@export var margin_container: MarginContainer
@export var label: Label

@export_group("") 
@export_multiline var text: String = ""

var node_ref: Node2D


func _ready() -> void:
	E.player_entered_extraction_door_area.connect(func(player: Player, extraction_door: ExtractionDoor):
		text = "Press \"E\" to extract"
		text += "\n"
		text += "Extracted: 0/3"
		update()
		
		show_from_node(extraction_door)
		)
	
	E.player_exited_extraction_door_area.connect(func(player: Player, extraction_door: ExtractionDoor):
		hide_from_node(extraction_door)
		)
	
	E.skill_node_mouse_entered.connect(func(skill_node: SkillNode):
		show_from_node(skill_node)
		)
	
	E.skill_node_mouse_exited.connect(func(skill_node: SkillNode):
		hide_from_node(skill_node)
		)
	
	E.player_extracted.connect(func(player: Player):
		node_ref = null
		hide()
		)
	
	
	update()
	hide()


func show_from_node(arg_node_ref: Node2D) -> void:
	node_ref = arg_node_ref
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	show()


func hide_from_node(arg_node_ref: Node2D) -> void:
	if node_ref == arg_node_ref:
		node_ref = null
		hide()


func _process(_delta: float) -> void:
	update_position()



func update_position() -> void:
	if not is_instance_valid(node_ref):
		return
	
	var popup_pos: Vector2 = node_ref.get_global_transform_with_canvas().origin
	if node_ref.has_node("PopupMarker"):
		popup_pos = (node_ref.get_node("PopupMarker") as Marker2D).get_global_transform_with_canvas().origin
	
	position = popup_pos




func update() -> void:
	margin_container.size = Vector2.ZERO
	label.text = text
	await get_tree().process_frame
	margin_container.position.x = -(margin_container.size.x * 0.5) - 0.5
	margin_container.position.y = -margin_container.size.y - 4
