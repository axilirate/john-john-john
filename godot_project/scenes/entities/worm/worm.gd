class_name Worm extends CharacterBody2D



var acceleration: float = 0.01
var speed: float = 175.0

var target_dir: Vector2


#TODO: give it 2 states, over ground and under ground, while over ground, 
# make it be effected by gravity, while in the ground, make it turn towards the player.


func _physics_process(delta: float) -> void:
	if not is_instance_valid(World.player):
		return
	
	
	var new_target_dir: Vector2 = global_position.direction_to(World.player.global_position)
	target_dir = target_dir.lerp(new_target_dir, delta * 3.0).normalized()
	
	velocity = velocity.lerp(target_dir * speed, acceleration)
	
	
	move_and_slide()
