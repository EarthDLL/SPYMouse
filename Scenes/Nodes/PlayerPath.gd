@tool
extends Line2D
class_name PlayerPath

const touch_rect := Rect2(-13,-13,26,26)

var recording := false
var drag_index : int = -1
var point_state : int = 1
#2-正常 1-指向
@onready var point: Sprite2D = $Point
#@onready var player : Player = null
@onready var collisioner: CollisionShape2D = $TestBody/Collision
@onready var test_body: CharacterBody2D = $TestBody
@onready var collect_area: Area2D = $Point/CollectArea

#定义灵敏度，值越大越不灵敏
@export var min_length : int = 5
@export var is_pickable := true

var is_interactable := false
#防止交互点无法拖路径，只有覆盖的area为0时才会设置为true

#var line := Vector2.ZERO
#func _draw() -> void:
	#if get_point_count() > 0:
		#var from := get_point_position(0)
		#draw_line(from,from + line,Color(1,1,1),3)

func player_seek_record(index : int , pos : Vector2 ) -> void:
	if !is_pickable:
		return
	if !Game.current_level.started:
		Game.current_level.start()
	if BgLayer.is_black_screen_poping():
		BgLayer.hide_black_screen()
	Game.current_level.data.total_paths += 1
	
	clear_all_points()
	set_point_state(2)

	point.global_position = pos
	add_a_point(pos)
	recording = true
	is_interactable = false
	drag_index = index
	
func rotate_point(pos : Vector2) -> void:
	point.rotation = point.global_position.angle_to_point(pos) - PI/2

func _physics_process(delta: float) -> void:
	if point_state == 2:
		var areas := collect_area.get_overlapping_areas()
		if areas.size() == 0:
			is_interactable = true
		if is_interactable:
			for area : Area2D in areas:
				if (area.is_in_group("Access") || area.is_in_group("Door")):
					var door := area.get_parent() as AccessNode
					if door.is_opened:
						bright()
						set_point_state(1)
						recording = false
						update_point()
						rotate_point(door.get_point())
						if door is Door && door.is_opened:
							door.bright()

func enter_hole(hole : MouseHole) -> void:
	bright()
	set_point_state(1)
	recording = false
	update_point()
	rotate_point(hole.global_position)
					
func set_point_state(state : int) -> void:
	point_state = state
	point.frame = state
		
func try_add_point(pos : Vector2) -> void:
	if get_point_count() == 0:
		return
	var offest := pos - get_point_position(0)
	var result : KinematicCollision2D = null
	if offest.length_squared() >= min_length * min_length:
		if get_point_count() >= 1:
			test_body.position = get_point_position(0) 
			result = test_body.move_and_collide(offest)
		if result == null:
			add_a_point(pos)
		else:
			#var collision_direction := Vector2.from_angle(result.get_angle(Vector2(-1,0))-PI/2)
			var collision_direction := result.get_normal().rotated(PI/2)
			#line = result.get_normal() * 50
			#queue_redraw()
			var little_slide := result.get_normal().normalized()
			test_body.move_and_collide(little_slide)
			test_body.move_and_collide(result.get_remainder().project(collision_direction))
			test_body.move_and_collide(-little_slide)
			if test_body.global_position != get_point_position(0):
				add_a_point(test_body.global_position)
		test_body.position = point.position
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag && recording:
		if drag_index != event.index:
			return
			
		#更新判断
		try_add_point(make_input_local(event).position)
		
	if event is InputEventScreenTouch:
		if recording:
			if !event.is_pressed() && event.index == drag_index:
				drag_index = -1
				recording = false
		else:
			#因为Point的Scale为0.2，坐标系会放大5倍,/4是为了缩小检测框
			if event.is_pressed() && point.visible && point.frame == 2 && touch_rect.has_point(point.make_input_local(event).position/4):
				drag_index = event.index
				recording = true
				is_interactable = false
	
			
func clear_all_points() -> void:
	recording = false
	clear_points()
	update_point()
	
##move_length 上一次走过的长度
func get_move_pos(pos : Vector2 , length : float) -> Vector2:
	if get_point_count() >= 2:
		if pos != get_point_position(get_point_count()-1):
			add_point(pos)

		var left_length := length
		while left_length > 0 && get_point_count() >= 2:
			var count := get_point_count() -1
			var dis := get_point_position(count).distance_to(get_point_position(count-1))
			if dis <= left_length:
				remove_point(count)
				left_length -= dis
			else : 
				var after_move_pos :Vector2 = get_point_position(count).move_toward(get_point_position(count-1),left_length)
				add_point(after_move_pos,count)
				remove_point(count+1)
				left_length = 0
		update_point()
		var goal_pos := get_point_position(get_point_count()-1)
		return goal_pos - pos
	else:
		return Vector2()

func remove_begining_points(count :int)->void:
	if count > 0:
		for i in range(count):
			remove_point(0)
			
func update_point() -> void:
	if get_point_count() < 2:
		point.hide()
	else:
		point.show()
		point.position = get_point_position(0)
			
func add_a_point(pos:Vector2) -> void:
	add_point(pos,0)
	update_point()

func set_collision(collision : CollisionShape2D) -> void:
	collisioner.shape = collision.shape
	collisioner.position = collision.position
	
var bright_tween : Tween
func bright() -> void:
	if bright_tween != null && bright_tween.is_running():
		bright_tween.kill()
	bright_tween = create_tween()
	bright_tween.tween_property(self,"modulate",Color8(255,204,84,255),0.1)
	bright_tween.tween_interval(1)
	bright_tween.tween_property(self,"modulate",Color(1,1,1,1),0.1)
	
func collect_entity(body: Node2D) -> void:
	if body is CollectItem:
		if !body.is_collected:
			bright()
			body.bright()
