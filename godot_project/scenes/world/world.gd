class_name World extends Node2D

const COIN_BAG_SCENE: PackedScene = preload("res://scenes/coin_bag/coin_bag.tscn")

static var gravity: float = 7.5




func _ready() -> void:
	if D.coin_bag_to_spawn_coins > 0:
		var coin_bag: CoinBag = COIN_BAG_SCENE.instantiate()
		coin_bag.coins = D.coin_bag_to_spawn_coins
		D.coin_bag_to_spawn_coins = 0
		add_child(coin_bag)
		
		coin_bag.global_position = D.coin_bag_to_spawn_position
