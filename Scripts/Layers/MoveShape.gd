@tool
extends Control
class_name MoveShape

enum anima{
	IN,
	OUT
}

@export var shape : Texture2D:
	set(value):
		shape = value
		queue_redraw()
@export var shape_size : float = 1.0:
	set(value):
		shape_size = value
		queue_redraw()
@export var point : Vector2 = Vector2(0,0):
	set(value):
		point = value
		queue_redraw()
		
func _ready() -> void:
	clip_contents = true
	
func _draw() -> void:
	if shape == null:
		return
#		无图像时不绘制
	var rect := get_global_rect()
	var shape_rect := Rect2(Vector2(point.x - shape.get_size().x * shape_size *0.5,point.y - shape.get_size().y * shape_size*0.5),shape.get_size()*shape_size)
	
	draw_texture_rect(shape,shape_rect,false)
	if shape_rect.position.y > rect.position.y:
		draw_rect(Rect2(rect.position,Vector2(rect.size.x,shape_rect.position.y - rect.position.y)),Color(1,1,1,1))
	if shape_rect.end.y < rect.end.y:
		draw_rect(Rect2(Vector2(rect.position.x,shape_rect.end.y),Vector2(rect.size.x,rect.end.y - shape_rect.end.y)),Color(1,1,1,1))
	if shape_rect.position.x > rect.position.x:
		draw_rect(Rect2(Vector2(rect.position.x,shape_rect.position.y),Vector2(shape_rect.position.x - rect.position.x,shape_rect.size.y)),Color(1,1,1,1))
	if shape_rect.end.x < rect.end.x:
		draw_rect(Rect2(Vector2(shape_rect.end.x,shape_rect.position.y),Vector2(rect.end.x - shape_rect.end.x,shape_rect.size.y)),Color(1,1,1,1))
	
	
	
