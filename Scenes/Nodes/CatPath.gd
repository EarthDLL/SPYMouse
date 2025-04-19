@tool
extends Line2D
class_name CatPath

const size = Vector2(12,12)
const length = 26.0

@export var id : int = 0
@export var path_texture : Texture2D = null
@export var is_loop := false

func _draw() -> void:
	if points.size() >= 2:
		for index : int in points.size() - 1:
			var distance := points[index].distance_to(points[index + 1])
			if distance <= length * 2:
				draw_at(points[index].move_toward(points[index + 1],distance/2))
			else:
				var current_pos := points[index]
				var goal_pos := points[index + 1]
				var count : int = floori(distance/length)
				var correct_length := distance / count
				for i : int in count:
					draw_at(current_pos.move_toward(goal_pos,correct_length/2 + i * correct_length))
				
		
func draw_at(pos :Vector2) -> void:
	draw_texture_rect(path_texture,Rect2(pos - size/2,size),false)
