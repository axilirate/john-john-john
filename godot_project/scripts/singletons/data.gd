extends Node

var unlocked_skill_nodes: Array[StringName] = []
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
var player_dash_cd: float = 1.0
var player_speed: float = 25.0




func extract(extraction_door: ExtractionDoor) -> void:
	for coin in temp_collected_things:
		collected_things.push_back(coin)
	temp_collected_things.clear()
	
	change_extracted_coins(temp_coins)
	change_temp_coins(-temp_coins)
	reset_energy()



func unlock_skill_node(skill_node: SkillNode) -> void:
	if not unlocked_skill_nodes.has(skill_node.name):
		unlocked_skill_nodes.push_back(skill_node.name)
	active_skills.push_back(skill_node.resource)
	
	if is_instance_valid(skill_node.resource.upgrade_script):
		skill_node.resource.upgrade_script.new()
	
	E.skill_node_unlocked.emit()


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
