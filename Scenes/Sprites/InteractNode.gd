extends Node2D
class_name InteractNode

@export var main_sprite : Node2D = null

func bright() -> void:
	if is_instance_valid(main_sprite):
		main_sprite.scale = Vector2(1.5,1.5)
		var tween := create_tween()
		tween.tween_property(main_sprite,"scale",Vector2(1,1),0.5)
