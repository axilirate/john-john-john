class_name Player extends CharacterBody2D

enum State {
	HARD_FALL,
	DASH,
	DEAD,
	}

enum Cooldown {
	TAKE_DAMAGE,
	GHOST_TRAIL,
	DASH,
}


const TAKE_DAMAGE_COOLDOWN: float = 1.0
const TARGET_CONTROL: float = 750.0
const DASH_DURATION: float = 0.15
const DASH_FORCE: float = 175.0


@export_group("Nodes")
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@export var interaction_area: Area2D
@export var sprite: Sprite2D


var dash_direction: Vector2 = Vector2.ZERO
var last_input: Vector2 = get_input()
var coyote_time: float = 0.1

var control: float = TARGET_CONTROL
var hit_stop_time: float = 0.0
var dash_time: float = 0.0
var air_time: float = 0.0

var cooldowns: Dictionary[Cooldown, float] = {}
var states: Array[State] = []
var animating: bool = false

var last_ghost_trail_pos: Vector2 = Vector2.INF
var color_tween: Tween = create_tween()

func _ready() -> void:
	E.restart_button_pressed.connect(func(): die())
	for idx in Cooldown.size():
		cooldowns[idx] = 0.0



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):
		if not is_on_floor():
			return
		
		for area in interaction_area.get_overlapping_areas():
			
			if area is ExtractionDoor:
				area.show_wall(global_position)
				extract(area.global_position)
				D.extract(area)
				
				E.player_extracted.emit(self)
			
			if area is SkillBook:
				D.temp_collected_things.push_back(area.name)
				area.learn()
	
	if event.is_action_pressed("dash"):
		try_to_dash()




func _physics_process(delta: float) -> void:
	if states.has(State.DEAD):
		return
		
	if not animating:
		process_last_input.call_deferred()
		process_cooldowns(delta)
		process_hit_stop(delta)
		process_energy(delta)
		
		process_air_time(delta)
		process_control(delta)
		process_hard_fall()
		
		process_velocity(delta)
		var collision: KinematicCollision2D = move_and_collide(velocity * delta, true)
		process_collision(collision)
		move_and_slide()
	
	
	process_visuals(delta)




func add_state(state: State) -> void:
	if states.has(state):
		return
	states.push_back(state)




func die() -> void:
	D.temp_collected_things.clear()
	D.temp_active_skills.clear()
	animation_tree.active = false
	animation_player.play("hit")
	add_state(State.DEAD)
	E.player_died.emit(self)
	
	await animation_player.animation_finished
	hide()


func process_last_input() -> void:
	last_input = get_input()



func process_cooldowns(delta: float) -> void:
	for cd in cooldowns:
		cooldowns[cd] = maxf(0.0, cooldowns[cd] - delta)



func process_hit_stop(delta: float) -> void:
	if hit_stop_time > 0.0:
		hit_stop_time -= delta / Engine.time_scale
		Engine.time_scale = 0.1
		return
	
	Engine.time_scale = 1.0



func process_energy(delta: float) -> void:
	D.change_curr_energy(-delta)
	if D.player_curr_energy <= 0:
		die()


func process_air_time(delta) -> void:
	if is_on_floor():
		air_time = 0.0
		return
	
	air_time += delta


func process_control(delta: float) -> void:
	control = move_toward(control, 750.0, delta * 275.0)


func process_hard_fall() -> void:
	if is_on_floor():
		states.erase(State.HARD_FALL)
	
	if velocity.y < 0 and just_released_jump():
		add_state(State.HARD_FALL)



func process_visuals(delta) -> void:
	process_animation_tree()
	process_sprite(delta)
	
	process_ghost_trail()



func process_velocity(delta) -> void:
	process_horizontal_movement(delta)
	process_gravity()
	process_jump(delta)
	process_dash(delta)



func process_gravity() -> void:
	velocity.y += World.gravity
	
	if is_on_floor() and cooldowns[Cooldown.TAKE_DAMAGE] == 0.0:
		velocity.y = 0



func process_jump(delta: float) -> void:
	var input: Vector2 = get_input()
	
	if air_time < coyote_time and just_pressed_jump():
		velocity.y -= D.player_jump_power
	
	if not is_equal_approx(velocity.y, 0.0):
		if velocity.y < 0 and states.has(State.HARD_FALL):
			velocity.y = lerp(velocity.y, 0.0, delta * 25)




func process_dash(delta: float) -> void:
	if not states.has(State.DASH):
		return
	
	velocity = (dash_direction * (DASH_FORCE + D.player_speed)) / pow(1.0 + dash_time, 10)
	dash_time += delta
	
	if dash_time >= DASH_DURATION:
		states.erase(State.DASH)


func try_to_dash() -> void:
	if not D.has_active_skill(Skills.DASH):
		return
	
	if cooldowns[Cooldown.DASH] > 0.0:
		return
	
	dash_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	cooldowns[Cooldown.TAKE_DAMAGE] = DASH_DURATION
	cooldowns[Cooldown.DASH] = D.player_dash_cd
	add_state(State.DASH)
	dash_time = 0.0
	control = 0.0
	
	color_tween.kill()
	color_tween = create_tween()
	
	sprite.modulate = Skills.DASH.color
	color_tween.tween_property(sprite, "modulate", Skills.DASH.color.lerp(Color("ff980d"), 0.75), D.player_dash_cd)
	color_tween.tween_property(sprite, "modulate", Skills.DASH.color, 0.1)
	color_tween.tween_property(sprite, "modulate", Color("ff980d"), 0.5).set_ease(Tween.EASE_OUT)





func process_collision(collision: KinematicCollision2D) -> void:
	if not is_instance_valid(collision):
		return
	
	if collision.get_collider() is Spikes:
		die()



func process_horizontal_movement(delta: float) -> void:
	var input: Vector2 = get_input()
	var target_velocity: float = input.x * D.player_speed
	velocity.x = move_toward(velocity.x, target_velocity, delta * control)








func process_sprite(_delta: float) -> void:
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
	var is_in_air: bool = not is_on_floor()
	if states.has(State.DASH):
		is_in_air = true
	
	#if not animation_tree["parameters/air_jump_one_shot/active"]:
		#animation_tree["parameters/air_jump_blend/blend_amount"] = int(flipped)
	
	if animating:
		run_time_scale = 0.85
		is_running = true
	
	animation_tree["parameters/run_blend/blend_amount"] = int(is_running)
	animation_tree["parameters/air_blend/blend_amount"] = int(is_in_air)
	
	
	animation_tree["parameters/run_time_scale/scale"] = run_time_scale




func process_ghost_trail() -> void:
	if not states.has(State.DASH):
		last_ghost_trail_pos = Vector2.INF
		return
	
	if cooldowns[Cooldown.GHOST_TRAIL] > 0.0:
		return
	cooldowns[Cooldown.GHOST_TRAIL] = 0.025
	
	if not last_ghost_trail_pos == Vector2.INF:
		if last_ghost_trail_pos.distance_to(sprite.global_position) < 10:
			return
	
	var ghost_trail: Sprite2D = sprite.duplicate()
	ghost_trail.set_script(preload("res://scripts/nodes/ghost_trail.gd"))
	ghost_trail = ghost_trail as GhostTrail
	
	ghost_trail.global_position = sprite.global_position
	last_ghost_trail_pos = ghost_trail.global_position
	
	ghost_trail.top_level = true
	
	await get_tree().create_timer(0.025).timeout
	
	add_child(ghost_trail)
	ghost_trail.z_index = -1
	ghost_trail.init()
	
	Pixel.snap(ghost_trail)
	





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



func take_damage(source: Vector2) -> void:
	if cooldowns[Cooldown.TAKE_DAMAGE] > 0.0:
		return
	
	var dir: Vector2 = global_position.direction_to(source)
	cooldowns[Cooldown.TAKE_DAMAGE] = TAKE_DAMAGE_COOLDOWN
	blink(TAKE_DAMAGE_COOLDOWN)
	velocity.x = -dir.x * 75
	velocity.y = -125
	hit_stop_time = 0.15
	control = 0.0
	
	
	color_tween.kill()
	color_tween = create_tween()
	sprite.modulate = Color("b4202a")
	color_tween.tween_property(sprite, "modulate", Color("ff980d"), 0.15).set_ease(Tween.EASE_IN)




func blink(duration: float) -> void:
	var blink_time := 0.1  # how fast the blink toggles
	var elapsed := 0.0
	while elapsed < duration:
		await get_tree().create_timer(blink_time).timeout
		sprite.visible = not sprite.visible
		elapsed += blink_time
	sprite.visible = true  # restore




func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is ExtractionDoor:
		E.player_entered_extraction_door_area.emit(self, area)
	
	if area is SkillBook:
		E.player_entered_skill_book_area.emit(self, area)
	
	if area is Coin:
		D.temp_collected_things.push_back(area.name)
		D.change_temp_coins(1)
		area.collect()



func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is ExtractionDoor:
		E.player_exited_extraction_door_area.emit(self, area)
	
	if area is SkillBook:
		E.player_exited_skill_book_area.emit(self, area)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Enemy:
		take_damage(body.global_position)
