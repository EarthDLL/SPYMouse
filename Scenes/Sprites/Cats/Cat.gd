extends CharacterBody2D
class_name Cat

enum STATE {
	IDLE,
	WALK,
	CHASING,
	FOUND,
	BACK,
	ANIMA,
	SHOOT,
	SLEEP
}

enum VIEW_DIRECTION{
	UP,
	LEFT_UP,
	LEFT_DOWN,
	RIGHT_UP,
	RIGHT_DOWN,
	DOWN,
	LEFT,
	RIGHT,
}

enum CATCH_TYPE{
	CATCH
}

signal complete_path

var signs : Array[Texture2D] = [
	preload("res://Resource/sprites/cat_peer.png"),
	preload("res://Resource/sprites/cat_alert.png"),
	preload("res://Resource/sprites/cat_angry.png"),
]
#发现玩家，撞击玩家，丢失玩家

@onready var anima: AnimationPlayer = $Anima
@onready var sign: Sprite2D = $Signs/Sign
@onready var sound_player: SoundPlayer = $SoundPlayer
@onready var sprite: Sprite2D = $Sprite

@export var eye: AnimatedSprite2D = null
@export var state : STATE = STATE.IDLE
@export var speed := 1.2
@export var chasing_speed := 2.2
@export var id := 0
@export var is_sleepable := true

var path :CatPath = null
var view_direction_vector := Vector2(0,-1)
var view_direction : VIEW_DIRECTION = VIEW_DIRECTION.UP

var target : Player = null
var is_target_in_view := false
var back_point := Vector2()
var final_target_position := Vector2()
var current_path_index := 0

func get_back_point() -> void:
	var cloest_point := path.to_global(path.points[current_path_index])
	var cloest_dis := global_position.distance_squared_to(cloest_point)
	for index in path.points.size():
		var dis := global_position.distance_squared_to(path.to_global(path.points[index]))
		if dis < cloest_dis:
			cloest_point = path.points[index]
			cloest_dis = dis
			current_path_index = index
	back_point = cloest_point
	
func is_active() -> bool:
	return true
	
func lose_target_view() -> void:
	eye.global_position = target.global_position
	final_target_position = target.global_position
	target = null
	is_target_in_view = false
	
func lose_target() -> void:
	eye.hide()
	sound_player.play_sound("Lost")
	show_sign(2,Vector2(0,-60),0.8)
	state = STATE.ANIMA
	play_direction_anima(view_direction,"Anger")
	await anima.animation_finished
	get_back_point()
	state = STATE.BACK
	
	
func has_target() -> bool:
	return target != null

func get_speed() -> float:
	match state:
		STATE.CHASING:
			return chasing_speed
	return speed

func match_path() -> void:
	for node in get_tree().get_nodes_in_group("CatPath"):
		if node is CatPath:
			if node.id == id:
				path = node
				
func play_direction_anima(dir : VIEW_DIRECTION , id : String) -> void:
	match dir:
		VIEW_DIRECTION.UP:
			anima.play(id + "Up")
		VIEW_DIRECTION.DOWN:
			anima.play(id + "Down")
		VIEW_DIRECTION.LEFT:
			anima.play(id + "Left")
		VIEW_DIRECTION.RIGHT:
			anima.play(id + "Right")
		VIEW_DIRECTION.LEFT_UP:
			anima.play(id + "LeftUp")
		VIEW_DIRECTION.LEFT_DOWN:
			anima.play(id + "LeftDown")
		VIEW_DIRECTION.RIGHT_UP:
			anima.play(id + "RightUp")
		VIEW_DIRECTION.RIGHT_DOWN:
			anima.play(id + "RightDown")

func set_direction_by_vector2(direction : Vector2) -> void:
	var direction_index := floori((direction.angle() + PI)/(PI/8))
	match direction_index:
		0,15:
			set_view_direction(Cat.VIEW_DIRECTION.LEFT)
		1,2:
			set_view_direction(Cat.VIEW_DIRECTION.LEFT_UP)
		3,4:
			set_view_direction(Cat.VIEW_DIRECTION.UP)
		5,6:
			set_view_direction(Cat.VIEW_DIRECTION.RIGHT_UP)
		7,8:
			set_view_direction(Cat.VIEW_DIRECTION.RIGHT)
		9,10:
			set_view_direction(Cat.VIEW_DIRECTION.RIGHT_DOWN)
		11,12:
			set_view_direction(Cat.VIEW_DIRECTION.DOWN)
		13,14:
			set_view_direction(Cat.VIEW_DIRECTION.LEFT_DOWN)

var sign_tween : Tween
func show_sign(index : int , pos :Vector2 , time : float) -> void:
	sign.texture = signs[index]
	sign.position = pos
	sign.show()
	if sign_tween != null && sign_tween.is_running():
		sign_tween.kill()
	sign_tween = create_tween()
	sign_tween.tween_interval(time)
	await sign_tween.finished
	sign.hide()
	
func set_view_direction(dir : VIEW_DIRECTION) -> void:
	view_direction = dir
	match dir:
		VIEW_DIRECTION.UP:
			view_direction_vector = Vector2(0,-1)
		VIEW_DIRECTION.DOWN:
			view_direction_vector = Vector2(0,1)
		VIEW_DIRECTION.LEFT:
			view_direction_vector = Vector2(-1,0)
		VIEW_DIRECTION.RIGHT:
			view_direction_vector = Vector2(1,0)
		VIEW_DIRECTION.LEFT_UP:
			view_direction_vector = Vector2(-1,-1)
		VIEW_DIRECTION.LEFT_DOWN:
			view_direction_vector = Vector2(-1,1)
		VIEW_DIRECTION.RIGHT_UP:
			view_direction_vector = Vector2(1,-1)
		VIEW_DIRECTION.RIGHT_DOWN:
			view_direction_vector = Vector2(1,1)
				
func follow_path() -> Vector2:
	if path != null:
		var pos := path.points[current_path_index]
		if path.to_global(pos).distance_to(global_position) < 5:
			next_path_point()
			pos = path.points[current_path_index]
		var direction := (pos - global_position).normalized()
		move_and_collide(direction * get_speed())
		if state == STATE.IDLE:
			state = STATE.WALK
		return direction
	return Vector2()
	
var is_path_back := false
func next_path_point() -> void:
	if path.is_loop:
		if current_path_index == 0:
			is_path_back = false
			current_path_index += 1
			emit_signal("complete_path")
		elif current_path_index == path.points.size() - 1:
			is_path_back = true
			current_path_index -= 1
			emit_signal("complete_path")
		else:
			if is_path_back:
				current_path_index -= 1
			else:
				current_path_index += 1
	else:
		current_path_index = (current_path_index + 1)%path.points.size()
		if current_path_index == 0:
			emit_signal("complete_path")
		
func update_target(player : Player) -> void:
	if player == null:
		if target != null:
			lose_target_view()
	else:
		if player != target:
			target = player
			discover_target()

func discover_target() -> void:
	is_target_in_view = true
	eye.hide()
	set_direction_by_vector2(target.global_position - global_position)
	if state != STATE.CHASING && state != STATE.SHOOT:
		Game.change_level_data_by_adding("found_time" , 1)
		#Game.current_level.data.found_time += 1
		sound_player.play_sound("Discover")
		play_direction_anima(view_direction,"Found")
		state = STATE.FOUND
		show_sign(0,Vector2(0,-60),1.6)
		await get_tree().create_timer(0.5).timeout
		state = STATE.CHASING
