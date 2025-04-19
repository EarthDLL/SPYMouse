extends Node
class_name SpecialModeHiddenCat

func _ready() -> void:
	for cat : Cat in get_tree().get_nodes_in_group("Cat"):
		if is_instance_valid(cat):
			cat.sprite.hide()
