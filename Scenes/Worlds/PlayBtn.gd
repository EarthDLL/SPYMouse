extends TouchScreenButton


@export var font : Font = null
@export var size : float = 32
@export var text : String = ""

func _draw() -> void:
	if font != null:
		var length := font.get_string_size(text,HORIZONTAL_ALIGNMENT_CENTER,-1,size)
		draw_string(font,Vector2(51-length.x/2,52+length.y/4),text,HORIZONTAL_ALIGNMENT_CENTER,-1,size)
