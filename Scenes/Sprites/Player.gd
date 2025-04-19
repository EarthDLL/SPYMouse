extends Charecter
class_name Player

signal update_cheese
signal access_anima_finished
signal hole_changed
signal picked_cheese
signal is_walking_changed

enum State {
	STAND,
	IDLE,
	WALK,
	DIE,
	ACCESS,
	CATCHED,
	INHOLE,
}

@onready var smokes: Node2D = $Smokes
@onready var collecting_area: Area2D = $CollectingArea
@onready var anima: AnimationPlayer = $Anima
@onready var sound_player: SoundPlayer = $SoundPlayer
@onready var navigation_point: Node2D = $NavigationPoint
@onready var sprite: Sprite2D = $Sprite2D
var path : PlayerPath = null :
	set(value):
		path = value
		if is_instance_valid(path):
			path.set_collision($Shape)


@export var speed : float = 1.8
@export var touch_rect : Rect2 = Rect2(-30,-40,60,60)
@export var collectable_items_count : int = 1
var state : State = State.IDLE:
	set(v):
		if state != v:
			if v == State.WALK:
				emit_signal("is_walking_changed",true)
			else:
				emit_signal("is_walking_changed",false)
		state = v
		

var collected_items : Array[CollectItem] = []
var pepper_effect : PepperEffect = null :
	set(value):
		pepper_effect = value
		if is_instance_valid(value):
			sprite.material.set_shader_parameter("weight",0.5)
var target_move := Vector2()
var stand_state := 0
#0-正方向 1-左 2-右 3-后 
var current_hole : int = -1:
	set(value):
		current_hole = value
		emit_signal("hole_changed")

##last_length 存放上一次移动的距离
var last_length : float = 0

var last_little_cheese_score := 1
var last_little_cheese_time := 0

func _unhandled_input(event: InputEvent) -> void:
	if path != null && is_active():
		if event is InputEventScreenTouch:
			if touch_rect.has_point(make_input_local(event).position):
				path.player_seek_record(event.index , global_position)
			
func _enter_tree() -> void:
	Game.current_player = self
	

func _ready() -> void:
	anima.play("CheckMap")
	
func get_navigation_position() -> Vector2:
	return navigation_point.global_position
	
func eat_food_anima() -> void:
	set_physics_process(false)
	var node : Sprite2D = $Sprite2D
	node.texture = load("res://Resource/sprites/player_eatcheese.png")
	node.vframes = 1
	node.hframes = 16
	anima.play("EatFood")
	
func get_speed() -> float:
	var rate := 1.0
	for item : CollectItem in collected_items:
		if is_instance_valid(item):
			rate = rate * item.weight_rate
	if is_instance_valid(pepper_effect):
		rate = rate * (2.5 if pepper_effect.is_large else 1.8)
	return speed * rate

func _physics_process(delta: float) -> void:
	if path == null:
		return
	var move_before_pos := position
	
	var move := Vector2()
	if state == State.STAND || state == State.WALK || state == State.IDLE:
		move = path.get_move_pos(global_position,get_speed())
		if move != Vector2.ZERO:
			state = State.WALK
	elif state == State.ACCESS:
		move = target_move * delta * 3
	
	if move != Vector2.ZERO:
		var angle := int(move.angle()/(PI/16))
		if Engine.get_physics_frames()%5 == 0:
			match angle:
				0:
					anima.play("Right")
					stand_state = 2
				-1,-2:
					anima.play("R10")
					stand_state = 3
				-3,-4:
					anima.play("R11")
					stand_state = 3
				-5,-6:
					anima.play("R12")
					stand_state = 3
				-7,-8:
					anima.play("Up")
					stand_state = 3
				-9,-10:
					anima.play("R1")
					stand_state = 3
				-11,-12:
					anima.play("R2")
					stand_state = 3
				-13,-14:
					anima.play("R3")
					stand_state = 3
				-15,15:
					anima.play("Left")
					stand_state = 1
				1,2:
					anima.play("R9")
					stand_state = 2
				3,4:
					anima.play("R8")
					stand_state = 2
				5,6:
					anima.play("R7")
					stand_state = 0
				7,8:
					anima.play("Down")
					stand_state = 0
				9,10:
					anima.play("R6")
					stand_state = 0
				11,12:
					anima.play("R5")
					stand_state = 1
				13,14:
					anima.play("R4")
					stand_state = 1
	elif state == State.STAND || state == State.WALK:
		state = State.STAND
		match stand_state:
			0:
				anima.play("StandDown")
			1:
				anima.play("StandDownLeft")
			2:
				anima.play("StandDownRight")
			3:
				anima.play("StandUp")
	move_and_collide(move)
	for body in collecting_area.get_overlapping_bodies():
		collect_entity(body)
	if is_active() && is_instance_valid(pepper_effect):
		smokes.emitting = true
		if Engine.get_physics_frames() % 60 == 0:
			pepper_effect.left_time -= 1
		if pepper_effect.left_time == 0:
			pepper_effect = null
			sprite.material.set_shader_parameter("weight",0.0)
		elif pepper_effect.left_time / pepper_effect.total_time < 0.5:
			if !is_instance_valid(pepper_effect.timer) || pepper_effect.timer.time_left == 0:
				pepper_effect.timer = get_tree().create_timer(pepper_effect.left_time / pepper_effect.total_time)
				pepper_effect.is_shining = !pepper_effect.is_shining
				if pepper_effect.is_shining:
					sprite.material.set_shader_parameter("weight",0.0)
				else:
					sprite.material.set_shader_parameter("weight",0.5)
	else:
		smokes.emitting = false
func anima_finished(id : StringName) -> void:
	if id == "CheckMap":
		anima.play("StandDown")
		state = State.STAND
		
func access_enter_finished() -> void:
	emit_signal("access_anima_finished")
func get_collected_cheese_count() -> int:
	var count := 0
	for item : CollectItem in collected_items:
		if item is Cheese:
			count += 1
	return count
	
func deal_all_items() -> void:
	while collected_items.has(null):
		collected_items.erase(null)
	for index in collected_items.size():
		if index == 0:
			collected_items[0].follower = self
		else:
			collected_items[index].follower = collected_items[index - 1]

func collect_entity(body: Node2D) -> void:
	if collected_items.size() >= collectable_items_count:
		return
	if body is Cheese && is_active():
		if !body.is_collected:
			collected_items.append(body)
			body.collect(self)
			sound_player.play_sound("GetCheese")
			deal_all_items()
			emit_signal("update_cheese",get_collected_cheese_count())
			emit_signal("picked_cheese")
	elif body is CollectItem && is_active():
		if !body.is_collected:
			collected_items.append(body)
			body.collect(self)
			sound_player.play_sound(body.collect_sound_id)
			deal_all_items()
			emit_signal("update_cheese",get_collected_cheese_count())
			
func get_collected_cheeses() -> Array[Cheese]:
	var value : Array[Cheese] = []
	for item in collected_items:
		if item is Cheese:
			value.append(item)
	return value
	
func is_active() -> bool:
	if state == State.DIE || state == State.ACCESS || state == State.CATCHED || state == State.INHOLE:
		return false
	return true
	
func enter_access(pos : Vector2 , item_pos : Vector2, is_finished : bool) -> void:
	var current_layer := collision_layer
	var current_mask := collision_mask
	var current_scale := scale
	path.clear_all_points()
	target_move = pos - global_position
	collision_layer = 0
	collision_mask = 0
	state = State.ACCESS
	
	var tween := create_tween()
	tween.tween_property(self,"scale",Vector2(0,0),0.4)
	
	if !is_finished:
		for index in collected_items.size():
			collected_items[index].anima_to_access(item_pos,index)
	
	await tween.finished
	hide()
	
	if !is_finished:
		await access_anima_finished
		collision_layer = current_layer
		collision_mask = current_mask
		scale = current_scale
		show()
		state = State.STAND


func collect_area(area : Area2D) -> void:
	if area.is_in_group("Door"):
		var door := area.get_parent() as Door
		if door.is_opened:
			Game.current_level.complete()
			enter_access(door.get_point(),door.get_item_point(),true)
			
			for index in collected_items.size():
				collected_items[index].finish_to_door(door.get_point(),index)
			#玩家进洞时间+进洞数*0.1
			door.player_in_door(0.4 + 0.1 * collected_items.size())
			Game.current_level.commit_cheese(self,Level.COMMITTYPE.DOOR)
	elif area.is_in_group("LittleCheese"):
		area.collect()
	elif area.is_in_group("Access"):
		var access := area.get_parent() as AccessNode
		if access.is_opened:
			access.enter()
			enter_access(access.get_point(),access.get_item_point(),false)
func clear_all_cheese() -> void:
	for cheese : CollectItem in collected_items:
		cheese.unlock()
	collected_items = []

func be_catched(reason : Cat.CATCH_TYPE) -> void:
	if is_instance_valid(path):
		path.clear_all_points()
	state = State.CATCHED
	var anima_time := 0.0
	Game.current_level.show_sprite(global_position,"Fight",10)
	Game.current_level.fail(1,global_position)
	queue_free()
	
func update_little_cheese_score() -> void:
	if Time.get_ticks_msec() - last_little_cheese_time > 5000:
		last_little_cheese_score = 1
	else:
		last_little_cheese_score += 1
	last_little_cheese_time = Time.get_ticks_msec()

func clear_state() -> void:
	if is_instance_valid(path):
		path.clear_all_points()

func enter_hole(color : int , anima_pos : Vector2 , item_pos : Vector2) -> void:
	var current_layer := collision_layer
	var current_mask := collision_mask
	var current_scale := scale
	path.clear_all_points()
	collision_layer = 0
	collision_mask = 0
	state = State.INHOLE
	
	for index in collected_items.size():
		collected_items[index].anima_to_access(item_pos,index)
	
	var tween := create_tween()
	tween.tween_property(self,"scale",Vector2(0,0),0.3)
	tween.parallel().tween_property(self,"global_position",anima_pos,0.3)
	await tween.finished
	hide()
	collision_layer = current_layer
	collision_mask = current_mask
	scale = current_scale
	
	current_hole = color
	
func leave_hole(pos : Vector2) -> void:
	global_position = pos
	await get_tree().create_timer(0.05).timeout
	state = State.STAND
	current_hole = -1
	show()
