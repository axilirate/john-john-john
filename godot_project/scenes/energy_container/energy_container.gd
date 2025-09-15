class_name EnergyContainer extends HBoxContainer

const ENERGY_PROGRESS_SCENE: PackedScene = preload("res://scenes/energy_progress/energy_progress.tscn")

func _ready() -> void:
	E.player_curr_energy_changed.connect(update_curr)
	update_all()


func update_all() -> void:
	update_curr()
	update_max()


func update_max() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for _i in range(D.player_max_energy / B.T1_ENERGY_TIME):
		add_child(ENERGY_PROGRESS_SCENE.instantiate())


func update_curr() -> void:
	for idx in get_child_count():
		var child = get_child(idx) as EnergyProgress
		child.bar.value = (D.player_curr_energy - (idx * B.T1_ENERGY_TIME)) * (10.0 / B.T1_ENERGY_TIME)
		child.bar.max_value = 10
