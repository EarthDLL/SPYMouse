extends Object
class_name Animations

static func common_anima(object : Node , scale : bool = false) -> void:
	if object is Control:
		object.pivot_offset = object.size/2
	var tween := Game.create_tween()
	object.show()
	if scale:
		object.scale = Vector2(0.3,0.3)
		tween.tween_property(object,"scale",Vector2(1,1),0.15)
	tween.tween_property(object,"scale",Vector2(0.7,1),0.08)
	tween.tween_property(object,"scale",Vector2(1,0.7),0.08)
	tween.tween_property(object,"scale",Vector2(1,1),0.04)
	
static func pop(object : Node , up : bool = true) -> void:
	if object is Control:
		object.pivot_offset = object.size/2
	var tween := Game.create_tween()
	object.show()
	if up:
		object.scale = Vector2(0.3,0.3)
		tween.tween_property(object,"scale",Vector2(1,1),0.15)
	else:
		tween.tween_property(object,"scale",Vector2(0,0),0.15)

static func little_cheese_ainma(pos : Vector2 , score : int) -> void:
	var label := Label.new()
	label.label_settings = load("res://EngineResources/LabelSettings/LittleCheeseAnima.tres")
	label.z_index = 100
	label.z_as_relative = false
	label.text = str(score)
	Game.current_level.add_child(label)
	label.global_position = pos
	label.set_size(Vector2(0,0))
	var tween : Tween = Game.current_level.create_tween()
	tween.tween_property(label,"global_position",label.global_position+Vector2(5,-5),0.3)
	tween.tween_property(label,"global_position",label.global_position+Vector2(0,-10),0.3)
	tween.tween_property(label,"global_position",Game.current_level.game_bar.get_score_pos(pos),0.6)
	tween.finished.connect(label.queue_free)
	
