@tool
class_name CoinsLabel extends CustomLabel



func _ready() -> void:
	super._ready()
	World.player.coins_changed.connect(func():
		text = str(World.player.coins)
		)
