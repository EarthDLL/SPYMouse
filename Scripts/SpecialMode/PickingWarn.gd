extends Node
class_name SpecialModePickingWarn

func _ready() -> void:
	if is_instance_valid(Game.current_player):
		Game.current_player.picked_cheese.connect(warn)

func warn() -> void:
	for cat : Cat in get_tree().get_nodes_in_group("Cat"):
		if is_instance_valid(cat):
			if cat.state == Cat.STATE.IDLE ||cat.state == Cat.STATE.WALK ||cat.state == Cat.STATE.BACK:
				cat.update_target(Game.current_player)
