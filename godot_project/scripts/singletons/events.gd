extends Node

# Data
signal coins_changed

# Player
signal player_entered_extraction_door_area(player: Player, extraction_door: ExtractionDoor)
signal player_exited_extraction_door_area(player: Player, extraction_door: ExtractionDoor)
signal player_extracted(player: Player)

# SkillNode
signal skill_node_mouse_entered(skill_node: SkillNode)
signal skill_node_mouse_exited(skill_node: SkillNode)


signal confirmed_upgrades_animation_finished
signal extraction_animation_finished
signal confirmed_upgrades
