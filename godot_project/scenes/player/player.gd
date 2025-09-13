class_name Player extends CharacterController

signal coins_changed

var coins: int = 0



func change_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit()


func get_input() -> Vector2:
	var x: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y: int = int(Input.is_action_pressed("jump"))
	
	return Vector2(x, y)



func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Coin:
		area.collect()
		change_coins(1)
