@tool
class_name CoinsLabel extends CustomLabel



func _ready() -> void:
	super._ready()
	E.coins_changed.connect(func(): text = str(D.coins))
