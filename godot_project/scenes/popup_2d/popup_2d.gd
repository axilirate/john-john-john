class_name Popup2D extends Node2D

@export_group("Nodes")
@export var margin_container: MarginContainer
@export var cost_container: HBoxContainer
@export var name_label: Label
@export var cost_label: Label
@export var description_label: Label

@export_group("") 
var description_text: String = ""
var name_text: String = ""
var cost: int = 0

var node_ref: Node2D



func _ready() -> void:
	E.player_entered_extraction_door_area.connect(func(_player: Player, extraction_door: ExtractionDoor):
		name_text = "Coin Multiplier: x" + str(extraction_door.extraction_multiplier)
		description_text = "Press \"E\" to extract"
		description_label.modulate = Color("5f5f5f")
		name_label.modulate = Color("ff980d")
		cost = 0
		update()
		
		show_from_node(extraction_door)
		)
	
	E.player_exited_extraction_door_area.connect(func(_player: Player, extraction_door: ExtractionDoor):
		hide_from_node(extraction_door)
		)
	
	
	
	E.skill_node_mouse_entered.connect(func(skill_node: SkillNode):
		name_label.modulate = Color.WHITE
		update_from_skill_node(skill_node)
		show_from_node(skill_node)
		)
	
	E.skill_node_unlocked.connect(func():update_from_skill_node(node_ref))
	E.skill_node_locked.connect(func():update_from_skill_node(node_ref))
	
	E.skill_node_mouse_exited.connect(func(skill_node: SkillNode):
		hide_from_node(skill_node)
		)
	
	E.player_extracted.connect(func(_player: Player):
		node_ref = null
		hide()
		)
	
	
	update()
	hide()



func update_from_skill_node(skill_node: SkillNode) -> void:
	if not is_instance_valid(skill_node):
		return
	
	name_text = skill_node.resource.name
	description_text = skill_node.resource.description
	cost = 0
	
	if not D.unlocked_skill_nodes.has(skill_node.name):
		if skill_node.resource == Skills.SKILL_POINT:
			cost = D.get_skill_point_price()
	
	update()



func show_from_node(arg_node_ref: Node2D) -> void:
	scale = arg_node_ref.get_viewport().get_camera_2d().zoom
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
	name_label.text = name_text
	description_label.text = description_text
	cost_label.text = str(cost)
	
	name_label.visible = name_text.length() > 0
	description_label.visible = description_text.length() > 0
	cost_container.visible = cost > 0
	
	await get_tree().process_frame
	margin_container.size = Vector2.ZERO
	margin_container.item_rect_changed.emit()
	
	margin_container.position.x = -(margin_container.size.x * 0.5) - 0.5
	margin_container.position.y = -margin_container.size.y - 4
