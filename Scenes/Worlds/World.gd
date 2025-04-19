extends Node2D
class_name World

const unfinished = 0
const finished = 2

@onready var anima: AnimationPlayer = $Anima
@onready var play_bar: Node2D = $Play
@onready var play_bg: Sprite2D = $Play/PlayBg
@onready var play_btn: TouchScreenButton = $Play/Btn
@onready var player_path: PlayerPath = $PlayerPath

var path_data := []
var current_index : int = 0
@export var index := 1
@export var levels : Array[LevelIcon] = []
@export var high_light : Sprite2D = null
@export var level_buttom: Sprite2D = null
@export var default_position: Node2D = null
@export var player : Player = null
@onready var path_line: Line2D = $PathLine

var play_bg_tween : Tween = null
var play_center := Vector2()
var play_angle : float = 0.0

func _physics_process(delta: float) -> void:
	if play_bar.visible:
		var offest := Vector2.from_angle(play_angle) * 10
		play_angle += delta * PI
		if play_angle >= PI * 2:
			play_angle -= PI * 2
		play_bar.global_position = play_center + offest
	
func set_current(index : int , show_btn : bool = true) -> void:
	if current_index != index && show_btn && levels[index].line_index != -1 &&  levels[current_index].line_index != -1:
		var from : int = levels[current_index].line_index
		if player_path.get_point_count() > 0:
			from = path_data[0] + path_data[2] * (abs(path_data[0]-path_data[1])+1-player_path.get_point_count())
		var to : int = levels[index].line_index
		var direction :int = (1 if to > from else -1)
		path_data = [from,to,direction]
		player_path.clear_all_points()
		for i in range(from,to+direction,direction):
			player_path.add_a_point(path_line.to_global(path_line.get_point_position(i)))
	else:
		player.global_position = levels[index].global_position
		player.global_position.y -= 10
		player_path.clear_all_points()
		
	current_index = index
	update_level(index)
	if anima.is_playing():
		anima.stop()
	anima.play("Scale")
	if show_btn:
		show_play()
		
		
func start_level() -> void:
	player.global_position = levels[current_index].global_position
	player.global_position.y -= 10
	player_path.clear_all_points()
	var level := levels[current_index]
	if Save.has_level(level.level_id):
		Game.button_sound()
		player.eat_food_anima()
		BgLayer.anima(MoveShape.anima.IN,"blue","hole",level.global_position,true,true)
		await BgLayer.anima_finsished
		Game.jump_to_level(level.level_id)
		BgLayer.show_loading_text()
		
func _ready() -> void:
	BgLayer.try_anima(default_position.global_position)
	player.path = player_path
	var last_played_id : int = Save.get_setting("last_played_level",2)
	var has_last_level := false
	for i in levels.size():
		if levels[i] != null:
			update_level(i,true)
			if levels[i].level_id == last_played_id:
				set_current(i,false)
				has_last_level = true
	if !has_last_level:
		set_current(0,false)
	
func show_play() -> void:
	var icon : LevelIcon = levels[current_index]
	var offest := Vector2(-1,-1)
	match icon.play_btn_direction:
		LevelIcon.BTN_DIRECTION.LEFT_UP:
			play_bg.rotation_degrees = 45
		LevelIcon.BTN_DIRECTION.LEFT_DOWN:
			offest = Vector2(-1,1)
			play_bg.rotation_degrees = -45
		LevelIcon.BTN_DIRECTION.RIGHT_UP:
			offest = Vector2(1,-1)
			play_bg.rotation_degrees = 135
		LevelIcon.BTN_DIRECTION.RIGHT_DOWN:
			offest = Vector2(1,1)
			play_bg.rotation_degrees = -135
	play_bar.global_position = icon.global_position + offest * 70
	play_angle = 0
	play_center = play_bar.global_position
	play_bar.show()
	if play_bg_tween != null && play_bg_tween.is_running():
		play_bg_tween.kill()
	play_bg_tween = create_tween()
	play_bg_tween.tween_property(play_bg,"rotation_degrees",play_bg.rotation_degrees + 5 , 0.5)
	play_bg_tween.tween_property(play_bg,"rotation_degrees",play_bg.rotation_degrees - 5 , 1)
	play_bg_tween.tween_property(play_bg,"rotation_degrees",play_bg.rotation_degrees , 0.5)
	play_bg_tween.set_loops()
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			var pos : Vector2 = make_input_local(event).get_position()
			for i in levels.size():
				if levels[i].collect_rect.has_point(pos - levels[i].global_position):
					var before_index := current_index
					set_current(i)
					update_level(before_index)
					Game.play("Pop")

func update_level(index : int , first : bool = false) -> void:
	var level := levels[index]
	if first:
		var light := high_light.duplicate()
		level.add_child(light)
		level.has_light = true
	
	if index == current_index:
		set_level_lable(level.level_id)
		level_buttom.global_position = levels[index].global_position
		level_buttom.show()
		BgLayer.common_anima(level_buttom)
		if level.building != null:
			BgLayer.common_anima(level.building)
		level.get_child(0).hide()
	var level_id : int = level.level_id
	if Save.is_finish_level(level_id):
		level.get_child(0).hide()
		level.frame = finished
	elif index != current_index:
		if level.type == LevelIcon.TYPE.LEVEL:
			level.get_child(0).show()

func set_level_lable(id : int) -> void:
	var text := "Unknown"
	if Save.has_level(id):
		var info : LevelInfo = Save.get_level_info(id)
		if is_instance_valid(info):
			text = info.level_index + " " + info.level_name
	%LevelLabel.text = text

func back_to_start() -> void:
	var scene : PackedScene = load("uid://dyfhpn8jqrr71")
	Game.animaed_change_scene(scene,"blue","hole",player.global_position)
	BgLayer.show_loading_text()
