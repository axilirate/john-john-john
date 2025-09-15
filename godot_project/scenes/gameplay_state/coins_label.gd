@tool
class_name CoinsLabel extends CustomLabel


enum CoinType {COLLECTED, EXTRACTED}

var curr_coin_type: CoinType = CoinType.COLLECTED


func _ready() -> void:
	super._ready()
	E.player_extracted.connect(func(_player: Player):
		curr_coin_type = CoinType.EXTRACTED
		update()
		)
	
	E.confirmed_upgrades_animation_finished.connect(func():
		curr_coin_type = CoinType.COLLECTED
		update()
		)
	
	E.coins_changed.connect(update)


func update() -> void:
	match curr_coin_type:
		CoinType.EXTRACTED: text = str(D.extracted_coins)
		CoinType.COLLECTED: text = str(D.collected_coins)
	
