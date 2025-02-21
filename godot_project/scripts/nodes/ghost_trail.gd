class_name GhostTrail extends Sprite2D


var alpha: float = 1.0






func init() -> void:
	material = ShaderMaterial.new()
	material.shader = preload("res://resources/shaders/ghost_trail.gdshader")
	material.set_shader_parameter("color", modulate)
	material.set_shader_parameter("fill", true)



func _process(delta: float) -> void:
	alpha -= delta
	
	material.set_shader_parameter("alpha", alpha)
	
	if alpha <= 0.0:
		queue_free()
