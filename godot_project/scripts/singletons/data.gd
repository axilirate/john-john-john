extends Node

var extractions: Dictionary[StringName, int] = {}
var unlocked_skill_nodes: Array[StringName] = []
var active_skills: Array[SkillResource] = []
var collected_coins: int = 0
var extracted_coins: int = 0


# Player
var player_max_energy: float = B.T1_ENERGY_TIME * 3
var player_curr_energy: float = player_max_energy

var player_jump_power: float = 85.0
var player_speed: float = 25.0


# Coin Bag
var coin_bag_to_spawn_position: Vector2
var coin_bag_to_spawn_coins: int = 0



func extract(extraction_door: ExtractionDoor) -> void:
	if not extractions.has(extraction_door.name):
		extractions[extraction_door.name] = 0
	
	var max_amount: int = extraction_door.max_extraction - extractions[extraction_door.name]
	var extracted_amount: int = mini(max_amount, collected_coins)
	extractions[extraction_door.name] += extracted_amount
	change_collected_coins(-extracted_amount)
	change_extracted_coins(extracted_amount)
	reset_energy()



func unlock_skill_node(skill_node: SkillNode) -> void:
	if not unlocked_skill_nodes.has(skill_node.name):
		unlocked_skill_nodes.push_back(skill_node.name)
	active_skills.push_back(skill_node.resource)
	
	if is_instance_valid(skill_node.resource.upgrade_script):
		skill_node.resource.upgrade_script.new()
	
	E.skill_node_unlocked.emit()


func change_collected_coins(amount: int) -> void:
	D.collected_coins += amount
	E.coins_changed.emit()

func change_extracted_coins(amount: int) -> void:
	D.extracted_coins += amount
	E.coins_changed.emit()

func reset_collected_coins() -> void:
	collected_coins = 0
	E.coins_changed.emit()

func reset_energy() -> void:
	player_curr_energy = player_max_energy
	E.player_curr_energy_changed.emit()

func change_curr_energy(amount: float) -> void:
	player_curr_energy += amount
	E.player_curr_energy_changed.emit()


func get_extracted_door_coins(extraction_door: ExtractionDoor) -> int:
	if not extractions.has(extraction_door.name):
		return 0
	return extractions[extraction_door.name]
