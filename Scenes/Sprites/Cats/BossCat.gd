extends Cat
class_name BossCat

signal fail

const scan_angle = 120.0
var textures : Array[Texture2D] = [
	load("uid://bh3fn2x4bavra"),
	load("uid://b44arukyx52e3"),
	load("uid://cnh2d3owwbccq"),
	load("uid://di2wmtygauj74"),
	load("uid://ceb5s4j0ww27r"),
	load("uid://bee2m2kbjo3ot")
]
var is_finished := false
var is_started := false
#is_start为true后才开始检测玩家
@onready var view: RayCast2D = $View
@onready var catch_area: Area2D = $CatchArea

func set_texture(id : int):
	if id < textures.size():
		sprite.texture = textures[id]

func next_path_point() -> void:
	if current_path_index == path.points.size() - 1:
		set_physics_process(false)
		return
	super()
	
var arc_alpha : int = 60
func _draw() -> void:
	var angle := view_direction_vector.angle()/PI*180 + 90 - scan_angle/2
	draw_circle_arc_poly(Vector2(0,0),320,angle,angle + scan_angle,Color8(255,0,0,arc_alpha))
	
func _ready() -> void:
	await get_tree().physics_frame
	match_path()
	get_tree().create_timer(3.0).timeout.connect(func():
		var tween := create_tween()
		tween.tween_property(self,"arc_alpha",0,1)
		tween.finished.connect(queue_redraw))
	
func _process(delta: float) -> void:
	if arc_alpha > 0:
		queue_redraw()
	
func _physics_process(delta: float) -> void:
	if state == STATE.IDLE || state == STATE.WALK:
		var direction := follow_path()
		if direction != Vector2():
			set_direction_by_vector2(direction)
			play_direction_anima(view_direction,"")
	if !is_finished && is_started == true:
		scan_player()

func scan_player() -> void:
	var player = Game.current_player
	if is_instance_valid(player) && player.is_active():
		view.target_position = to_local(player.global_position)
		view.force_raycast_update()
		if !view.is_colliding():
			var angle := view_direction_vector.angle_to(to_local(player.global_position))
			if angle > -1.05 && angle < 1.05:
				emit_signal("fail")
				is_finished = true
				return
	for body in catch_area.get_overlapping_bodies():
		if body == player && player.is_active():
			body.be_catched(CATCH_TYPE.CATCH)
			sound_player.play_sound("Fight")
			hide()
			set_physics_process(false)

func draw_circle_arc_poly(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color):
	var nb_points := 32
	var points_arc := PackedVector2Array()
	points_arc.push_back(center)
	var colors := PackedColorArray([color])
	for i in range(nb_points + 1):
		var angle_point := deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
