class_name Worm extends CharacterBody2D

@export var ground_detection_area: Area2D
@export var body_line: Line2D

@export var segment_length: int = 3
@export var points: int = 10


@onready var in_ground: bool = is_in_ground()


var acceleration: float = 0.01
var gravity: float = 4.5
var speed: float = 125.0

var target_dir: Vector2



func _ready() -> void:
	body_line.points.clear()
	for point in points:
		body_line.add_point(Vector2.ZERO, point)


func _on_area_2d_body_entered(body: Node2D) -> void:
	in_ground = true

func _on_ground_detection_area_body_exited(body: Node2D) -> void:
	in_ground = false



func _process(delta: float) -> void:
	_process_body_line()



func _physics_process(delta: float) -> void:
	if not is_instance_valid(World.player):
		return
	
	_process_velocity(delta)
	
	move_and_slide()




func _process_body_line() -> void:
	body_line.set_point_position(0, global_position)
	
	for idx in body_line.get_point_count():
		if idx == 0:
			continue
		
		var last_point_pos: Vector2 = body_line.get_point_position(idx - 1)
		var curr_point_pos: Vector2 = body_line.get_point_position(idx)
		var new_point_pos: Vector2 = constrain_distance(curr_point_pos, last_point_pos, segment_length)
		
		body_line.set_point_position(idx, new_point_pos)
		
		#sprite.look_at(sprite.global_position + target_dir)



func _process_velocity(delta: float) -> void:
	if not in_ground:
		velocity.y += gravity
		velocity.y = min(125, velocity.y)
		target_dir = velocity.normalized()
		return
	
	
	var new_target_dir: Vector2 = global_position.direction_to(World.player.global_position)
	target_dir = target_dir.lerp(new_target_dir, delta * 10).normalized()
	
	velocity = target_dir * speed






func is_in_ground() -> bool:
	if ground_detection_area.get_overlapping_bodies().size():
		return true
	return false



func constrain_distance(current: Vector2, target: Vector2, max_dist: float) -> Vector2:
	var direction = current.direction_to(target)
	var distance = current.distance_to(target)
	if distance > max_dist:
		return target - direction * max_dist
	return current
