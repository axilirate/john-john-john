class_name CoinBag extends Area2D


@export var animation_player: AnimationPlayer
@export var ray_cast: RayCast2D

var coins: int



func _physics_process(delta: float) -> void:
	if not ray_cast.is_colliding():
		return
	global_position.y = ray_cast.get_collision_point().y
	print(ray_cast.get_collision_point())


func collect() -> void:
	var collection_time: float = 0.25
	animation_player.stop()
	var t1 = create_tween().tween_property(self, "global_position:y", global_position.y + 2, 0.1)
	await t1.finished
	create_tween().tween_property(self, "global_position:y", global_position.y - 5, collection_time)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(self, "modulate:a", 0, collection_time - 0.1).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(collection_time).timeout
	hide()
	queue_free()
