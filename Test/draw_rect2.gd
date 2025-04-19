extends Sprite2D


func _draw() -> void:
	draw_rect(Rect2(get_parent().touch_rect.position*5,get_parent().touch_rect.size*5),Color8(255,0,0,100),true)
