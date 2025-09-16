class_name GhostTrail extends Sprite2D


var alpha: float = 1.0






func init() -> void:
	material = ShaderMaterial.new()
	material.shader = preload("res://resources/shaders/ghost_trail.gdshader")
	material.set_shader_parameter("color", modulate)
	material.set_shader_parameter("fill", true)



func _process(delta: float) -> void:
	var scale_change: Vector2 = Vector2(delta, delta) * 15
	if alpha < 0.75:
		scale_change *= Vector2(delta, delta) * -5
	
	scale += scale_change
	scale = scale.clamp(Vector2(0.25, 0.25), Vector2.ONE)
	alpha -= delta
	
	material.set_shader_parameter("alpha", alpha)
	
	if alpha <= 0.0:
		queue_free()
