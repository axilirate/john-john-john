extends Node


var unlocked_skill_nodes: Array[String] = []
var active_skills: Array[SkillResource] = []
var coins: int





func change_coins(amount: int) -> void:
	D.coins += amount
	E.coins_changed.emit()
