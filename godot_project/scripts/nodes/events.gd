extends Node

# Player
signal player_entered_extraction_door_area(player: Player, extraction_door: ExtractionDoor)
signal player_exited_extraction_door_area(player: Player, extraction_door: ExtractionDoor)
signal player_coins_changed(player: Player)
signal player_extracted(player: Player)

# SkillNode
signal skill_node_mouse_entered(skill_node: SkillNode)
signal skill_node_mouse_exited(skill_node: SkillNode)


signal extraction_animation_finished
