extends Node2D

var texture = preload("res://Resource/sprites/smoke.png")
@onready var size : Vector2 = texture.get_size()
@export var emitting := false:
	set(v):
		emitting = v
		if v:
			updated = true
var updated := false
var smokes := []

func _process(delta: float) -> void:
	if smokes.size() > 0:
		queue_redraw()
	elif updated:
		queue_redraw()
		updated = false
		
func _physics_process(delta: float) -> void:
	if emitting:
		if Engine.get_physics_frames() % 40 == 0:
			smokes.append({
				"scale" : 0.4 ,
				"position" : get_parent().global_position,
				
			})
	for item in smokes:
		item.scale -= 0.006
		if item.scale <= 0.1:
			smokes.erase(item)
		
func _draw() -> void:
	for item in smokes:
		draw_texture_rect(texture,Rect2(item.position-size*item.scale/2,size*item.scale),false,Color(1,1,1,2.5*item.scale))
