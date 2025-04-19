extends TextureRect

signal pressed

var description : String = ""
var type : Achievement.TYPE 

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			emit_signal("pressed",type,description)
