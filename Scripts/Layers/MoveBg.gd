@tool
extends Control
class_name MoveBg

@export var bg_pic : Texture2D:
	set(value):
		bg_pic = value
		queue_redraw()

func _draw() -> void:
	if bg_pic == null:
		return
	draw_texture_rect(bg_pic,get_global_rect(),true)

func _ready() -> void:
	material = load("uid://bgcqws266isvk")
