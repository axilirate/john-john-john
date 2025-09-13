class_name CoinsLabel extends Label



func _ready() -> void:
	World.player.coins_changed.connect(func():
		text = str(World.player.coins)
		)
