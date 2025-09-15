class_name Player extends CharacterBody2D

enum State {
	HARD_FALL,
	DEAD,
	}


@export_group("Nodes")
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@export var interaction_area: Area2D
@export var sprite: Sprite2D


var last_input: Vector2 = get_input()
var coyote_time: float = 0.1

var air_time: float = 0.0

var states: Array[State] = []
var animating: bool = false


func _ready() -> void:
	E.restart_button_pressed.connect(func(): die())
	interaction_area.area_exited.connect(func(area: Area2D):
		if area is ExtractionDoor:
			E.player_exited_extraction_door_area.emit(self, area)
		)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):
		if not is_on_floor():
			return
		
		for area in interaction_area.get_overlapping_areas():
			var extraction_door: ExtractionDoor
			if area is ExtractionDoor:
				extraction_door = area as ExtractionDoor
			else:
				continue
			
			if not area.can_extract():
				return
			
			area.show_wall(global_position)
			extract(area.global_position)
			D.extract(area)
			
			E.player_extracted.emit(self)




func _physics_process(delta: float) -> void:
	if states.has(State.DEAD):
		return
		
	if not animating:
		process_last_input.call_deferred()
		process_energy(delta)
		
		process_air_time(delta)
		process_hard_fall()
		
		process_velocity(delta)
		var collision: KinematicCollision2D = move_and_collide(velocity * delta, true)
		process_collision(collision)
		move_and_slide()
	
	
	process_visuals()




func add_state(state: State) -> void:
	if states.has(state):
		return
	states.push_back(state)


func die() -> void:
	D.coin_bag_to_spawn_position = global_position
	D.coin_bag_to_spawn_coins = D.temp_coins
	animation_tree.active = false
	animation_player.play("die")
	add_state(State.DEAD)
	E.player_died.emit(self)
	
	await animation_player.animation_finished
	hide()


func process_last_input() -> void:
	last_input = get_input()




func process_energy(delta: float) -> void:
	D.change_curr_energy(-delta)
	if D.player_curr_energy <= 0:
		die()


func process_air_time(delta) -> void:
	if is_on_floor():
		air_time = 0.0
		return
	
	air_time += delta



func process_hard_fall() -> void:
	if is_on_floor():
		states.erase(State.HARD_FALL)
	
	if velocity.y < 0 and just_released_jump():
		add_state(State.HARD_FALL)



func process_visuals() -> void:
	process_animation_tree()
	process_sprite()



func process_velocity(delta) -> void:
	process_horizontal_movement()
	process_gravity()
	process_jump(delta)




func process_gravity() -> void:
	velocity.y += World.gravity
	
	if is_on_floor():
		velocity.y = 0



func process_jump(delta) -> void:
	var input: Vector2 = get_input()
	
	if air_time < coyote_time and just_pressed_jump():
		velocity.y -= D.player_jump_power
	
	if not is_equal_approx(velocity.y, 0.0):
		if velocity.y < 0 and states.has(State.HARD_FALL):
			velocity.y = lerp(velocity.y, 0.0, delta * 25)



func process_collision(collision: KinematicCollision2D) -> void:
	if not is_instance_valid(collision):
		return
	
	if collision.get_collider() is Spikes:
		die()


func process_horizontal_movement() -> void:
	var input: Vector2 = get_input()
	velocity.x = input.x * D.player_speed



func process_sprite() -> void:
	var flipped: bool = sprite.flip_h
	
	if velocity.x > 0.0:
		flipped = false
	
	if velocity.x < 0.0:
		flipped = true
	
	#if is_on_wall() and air_time.current > 0.1:
		#var normal: Vector2 = get_wall_normal()
		#flipped = normal.x == -1
	
	sprite.global_position = global_position + Vector2(0.0, -3.5)
	
	if is_on_floor():
		sprite.global_position.y = round(sprite.global_position.y) + 0.5
	
	if is_equal_approx(velocity.x, 0.0) and not animating:
		Pixel.snap(sprite)
	
	sprite.flip_h = flipped
	sprite.offset.x = 0




func process_animation_tree() -> void:
	if not is_instance_valid(animation_tree):
		return
	
	var is_running: bool = not is_equal_approx(velocity.x, 0.0) and not get_input().x == 0
	var run_time_scale: float = abs(velocity.x) / 34.0
	#if not animation_tree["parameters/air_jump_one_shot/active"]:
		#animation_tree["parameters/air_jump_blend/blend_amount"] = int(flipped)
	
	if animating:
		run_time_scale = 0.85
		is_running = true
	
	animation_tree["parameters/air_blend/blend_amount"] = int(not is_on_floor())
	animation_tree["parameters/run_blend/blend_amount"] = int(is_running)
	
	
	animation_tree["parameters/run_time_scale/scale"] = run_time_scale



func just_pressed_jump() -> bool:
	return last_input.y <= 0 and get_input().y > 0

func just_released_jump() -> bool:
	return last_input.y > 0 and get_input().y <= 0




func extract(area_position: Vector2) -> void:
	animation_tree["parameters/run_blend/blend_amount"] = 1
	animating = true
	
	if area_position.x <= global_position.x:
		create_tween().tween_property(self, "global_position:x", area_position.x - 15, 2.0)
		sprite.flip_h = true
	
	if area_position.x > global_position.x:
		create_tween().tween_property(self, "global_position:x", area_position.x + 15, 2.0)
		sprite.flip_h = false



func get_input() -> Vector2:
	var x: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y: int = int(Input.is_action_pressed("jump"))
	
	return Vector2(x, y)


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is ExtractionDoor:
		E.player_entered_extraction_door_area.emit(self, area)
	
	if area is Coin:
		D.collected_coins.push_back(area.name)
		D.change_temp_coins(1)
		area.collect()
	
	if area is CoinBag:
		area.collect()
		D.change_temp_coins(area.coins)
