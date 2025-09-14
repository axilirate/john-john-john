@tool
class_name CoinsLabel extends CustomLabel



func _ready() -> void:
	super._ready()
	E.player_coins_changed.connect(func(player: Player): text = str(player.coins))
