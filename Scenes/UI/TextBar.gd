extends Panel
class_name TextBar

@onready var label: Label = $Container/Panel/Texts/Text
@onready var container: AspectRatioContainer = $Container
@onready var title: Label = $Container/Panel/Label


func _on_back_pressed() -> void:
	Game.button_sound()
	Animations.pop(container,false)
	await get_tree().create_timer(0.2).timeout
	queue_free()

func popup() -> void:
	Game.button_sound()
	Animations.pop(container,true)
	show()

func set_title(text : String) -> void:
	title.set_text(text)
	
func set_text(text : String) -> void:
	label.set_text(text)
