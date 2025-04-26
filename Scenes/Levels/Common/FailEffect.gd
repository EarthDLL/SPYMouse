extends Node2D

var tween : Tween
var is_started := false
var length : float = 0
var alpha :float = 0
var offest : Vector2

func start(boss_pos : Vector2 , player_pos : Vector2) -> void:
	is_started = true
	show()
	global_position = boss_pos
	offest = player_pos - boss_pos
	tween = create_tween()
	tween.tween_property(self,"length",1,1.5)
	tween.tween_property(self,"alpha",1,0.5)
	tween.parallel().tween_property($Label,"visible",true,0.1)
	
func _process(delta: float) -> void:
	if is_started:
		queue_redraw()
		
func _draw() -> void:
	draw_dashed_line(Vector2(0,0),offest * length , Color(1,0,0),6,10.0,false)
	draw_circle(offest,40.0, Color(1,0,0,alpha) , false , 5)
	
