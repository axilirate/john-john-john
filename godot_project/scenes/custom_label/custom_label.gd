@tool
class_name CustomLabel extends Label



@export var shadow_color: Color
@export var default_font_size: int


func _ready() -> void:
	update()


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	update()


func update() -> void:
	for idx in get_child_count():
		var child = get_child(idx)
		if child is Label:
			var curr_font_size: int = get_theme_font_size("font_size")
			var growth: int = (curr_font_size / default_font_size)
			
			match idx:
				0: child.position = Vector2(1 * growth, -1 * growth)
				1: child.position = Vector2(-1 * growth, -1 * growth)
				2: child.position = Vector2(-1 * growth, -1 * growth)
				
				3: child.position = Vector2(1 * growth, 0)
				4: child.position = Vector2(-1 * growth, 0)
				
				5: child.position = Vector2(0, 1)
				6: child.position = Vector2(1 * growth, 1 * growth)
				7: child.position = Vector2(-1 * growth, 1 * growth)
				
				8: child.position = Vector2(0, 2)
				9: child.position = Vector2(1 * growth, 2 * growth)
				10: child.position = Vector2(-1 * growth, 2 * growth)
			
			
			child.modulate = shadow_color
			child.add_theme_font_size_override("font_size", curr_font_size)
			child.text = text


func apply_text(new_text: String) -> void:
	text = new_text
	update()
