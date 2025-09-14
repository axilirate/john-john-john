class_name Player extends CharacterController


@export var interaction_area: Area2D
var coins: int = 0




func _ready() -> void:
	interaction_area.area_entered.connect(func(area: Area2D):
		if area is ExtractionDoor:
			E.player_entered_extraction_door_area.emit(self, area)
		)
	
	interaction_area.area_exited.connect(func(area: Area2D):
		if area is ExtractionDoor:
			E.player_exited_extraction_door_area.emit(self, area)
		)




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):
		for area in interaction_area.get_overlapping_areas():
			if area is ExtractionDoor:
				area.show_wall(global_position)
				extract(area.global_position)



func extract(area_position: Vector2) -> void:
	animation_tree["parameters/run_blend/blend_amount"] = 1
	animating = true
	E.player_extracted.emit(self)
	
	if area_position.x <= global_position.x:
		create_tween().tween_property(self, "global_position:x", area_position.x - 15, 2.0)
		sprite.flip_h = true
	
	if area_position.x > global_position.x:
		create_tween().tween_property(self, "global_position:x", area_position.x + 15, 2.0)
		sprite.flip_h = false
	
	



func change_coins(amount: int) -> void:
	coins += amount
	E.player_coins_changed.emit(self)


func get_input() -> Vector2:
	var x: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y: int = int(Input.is_action_pressed("jump"))
	
	return Vector2(x, y)



func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Coin:
		area.collect()
		change_coins(1)
