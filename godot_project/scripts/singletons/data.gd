extends Node


var coins: int





func change_coins(amount: int) -> void:
	D.coins += amount
	E.coins_changed.emit()
