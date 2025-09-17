extends Node

var unlocked_skill_nodes: Array[StringName] = []
var temp_active_skills: Array[SkillResource] = []
var active_skills: Array[SkillResource] = []
var extracted_coins: int = 0
var temp_coins: int = 0

# World
var temp_collected_things: Array[StringName] = []
var collected_things: Array[StringName] = []


# Player
var player_max_energy: float = B.T1_ENERGY_TIME * 3
var player_curr_energy: float = player_max_energy

var player_jump_power: float = 85.0
var player_dash_cd: float = 2.5
var player_speed: float = 25.0




func extract(extraction_door: ExtractionDoor) -> void:
	for thing in temp_collected_things:
		collected_things.push_back(thing)
	
	for skill in temp_active_skills:
		active_skills.push_back(skill)
	
	temp_collected_things.clear()
	temp_active_skills.clear()
	
	change_extracted_coins(temp_coins)
	change_temp_coins(-temp_coins)
	reset_energy()




func unlock_skill_node(skill_node: SkillNode) -> void:
	if not unlocked_skill_nodes.has(skill_node.name):
		unlocked_skill_nodes.push_back(skill_node.name)
	active_skills.push_back(skill_node.resource)
	
	player_jump_power += skill_node.resource.bonus_jump_power
	player_speed += skill_node.resource.bonus_speed
	
	if not skill_node.cost == -1:
		change_extracted_coins(-skill_node.cost)
	
	E.skill_node_unlocked.emit()




func lock_skill_node(skill_node: SkillNode, emit: bool = true) -> void:
	if not unlocked_skill_nodes.has(skill_node.name):
		return
	
	unlocked_skill_nodes.erase(skill_node.name)
	active_skills.erase(skill_node.resource)
	
	player_jump_power -= skill_node.resource.bonus_jump_power
	player_speed -= skill_node.resource.bonus_speed
	
	if not skill_node.cost == -1:
		change_extracted_coins(skill_node.cost)
	
	for child in skill_node.get_children():
		if child is SkillNode:
			lock_skill_node(child, false)
	
	if emit:
		E.skill_node_locked.emit()






func change_temp_coins(amount: int) -> void:
	temp_coins += amount
	E.coins_changed.emit()


func change_extracted_coins(amount: int) -> void:
	D.extracted_coins += amount
	E.coins_changed.emit()


func reset_temp_coins() -> void:
	temp_coins = 0
	E.coins_changed.emit()


func reset_energy() -> void:
	player_curr_energy = player_max_energy
	E.player_curr_energy_changed.emit()


func change_curr_energy(amount: float) -> void:
	player_curr_energy += amount
	E.player_curr_energy_changed.emit()


func has_active_skill(skill_resource: SkillResource) -> bool:
	if temp_active_skills.has(skill_resource) or active_skills.has(skill_resource):
		return true
	return false
