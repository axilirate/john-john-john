class_name TransitionRect extends ColorRect


@export var animation_player: AnimationPlayer




func _ready() -> void:
	E.player_extracted.connect(func(player: Player):
		await get_tree().create_timer(0.5).timeout
		animation_player.play("show")
		await animation_player.animation_finished
		E.extraction_animation_finished.emit()
		animation_player.play("hide")
		)
	
	E.confirmed_upgrades.connect(func():
		await get_tree().create_timer(0.5).timeout
		animation_player.play("show")
		await animation_player.animation_finished
		E.confirmed_upgrades_animation_finished.emit()
		animation_player.play("hide")
	)
	
	hide()
