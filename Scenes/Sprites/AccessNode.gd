extends InteractNode
class_name AccessNode

@export var is_opened := false
@export var anima_point : Node2D = null
@export var item_point : Node2D = null
#ItemPoint为奶酪消失的位置，一般不在墙上
@export var target_part := 0

func access_open() -> void:
	pass
	
func access_close() -> void:
	pass

func get_point() -> Vector2:
	if is_instance_valid(anima_point):
		return anima_point.global_position
	return global_position

func get_item_point() -> Vector2:
	if is_instance_valid(item_point):
		return item_point.global_position
	return global_position

func enter() -> void:
	Game.current_level.jump_to_part(target_part)
