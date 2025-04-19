extends CharacterBody2D
class_name Charecter

func get_navigition_position() -> Vector2:
	return global_position
	
@export var collect_item_follow_length := 40.0
