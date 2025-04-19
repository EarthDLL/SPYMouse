extends Control

var points : Array = []

func _draw() -> void:
	draw_rect(Rect2(Vector2(),size),Color(0,0,0,1),true)
	for point :Vector2 in points:
		draw_circle(Game.global_pos_to_screen_pos(point),40,Color(1,1,1,1),true)
