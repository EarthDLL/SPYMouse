extends Sprite2D

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 15 == 0:
		frame = (frame+1)%3

func popup(pos : Vector2) -> void:
	global_position = pos
	global_position.y += randi_range(-20,20)
	var tween := create_tween()
	tween.tween_property(self,"global_position",global_position - Vector2(1000,2000),randi_range(17,20))

func _on_visible_screen_exited() -> void:
	queue_free()
