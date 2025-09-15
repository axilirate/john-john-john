class_name EscScreen extends MarginContainer



@export var restart_button: Button


func _ready() -> void:
	restart_button.pressed.connect(func(): E.restart_button_pressed.emit())
	E.player_died.connect(func(_player: Player): hide())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		visible = not visible
