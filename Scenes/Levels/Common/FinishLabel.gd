extends CanvasLayer

@onready var label: Label = $Label

signal finished

func show_text(text : String , is_finished : bool) -> void:
	label.text = text
	label.show()
	label.pivot_offset = label.size/2
	label.scale = Vector2(0,0)
	label.modulate.a = 0.0
	var tween := create_tween()
	if is_finished:
		tween.tween_property(label,"scale",Vector2(1,1),0.5)
		tween.parallel()
		tween.tween_property(label,"modulate",Color(1,1,1,1),0.5)
		tween.tween_interval(1.5)
		tween.tween_property(label,"scale",Vector2(2.5,2.5),0.3)
		tween.parallel()
		tween.tween_property(label,"modulate",Color(1,1,1,0),0.2)
	else:
		tween.tween_property(label,"scale",Vector2(1,1),3)
		tween.parallel()
		tween.tween_property(label,"modulate",Color(1,1,1,1),3)
		tween.tween_interval(0.1)
		tween.tween_property(label,"modulate",Color(1,1,1,0),3)
	tween.finished.connect(finish)

func finish() -> void:
	emit_signal("finished")
