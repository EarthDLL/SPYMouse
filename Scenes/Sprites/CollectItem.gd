extends CharacterBody2D
class_name CollectItem

enum STATE {
	IDLE,
	FOLLOW,
	FINISH
}

enum HIDE_TYPE{
	HOLE,
	ACCESS,
	NONE
}

const max_speed : float = 3
var current_speed := 0.0

var is_collected := false

@export var weight_rate := 1.0
@export var navigation: NavigationAgent2D = null
@export var sprite: Sprite2D = null
@export var follow_length := 40.0
@export var collect_sound_id : String = ""
var state : CollectItem.STATE = STATE.IDLE

var collecter : Charecter = null
var follower : Node2D = null
var hide_type : HIDE_TYPE = HIDE_TYPE.NONE

func finish_to_door(pos : Vector2,index : int = 0) -> void:
	
	state = CollectItem.STATE.FINISH
	pos = pos - (pos - global_position).normalized() * 20
	var tween := create_tween()
	tween.tween_property(self,"global_position",pos,0.4 + 0.1 * (index + 1))
	await tween.finished
	hide()
	
var move_tween : Tween 
func anima_to_access(pos : Vector2,index : int ) -> void:
	if is_instance_valid(move_tween):
		if move_tween.is_running():
			move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(self,"global_position",pos,0.4 + index *0.05)
	await move_tween.finished
	collect_hide()

func collect_hide() -> void:
	set_physics_process(false)
	hide()

func collect_show(pos : Vector2) -> void:
	if is_instance_valid(move_tween):
		if move_tween.is_running():
			move_tween.kill()
	set_physics_process(true)
	global_position = pos
	show()
	
var bright_tween : Tween
func bright() -> void:
	if !Game.current_level.is_item_collectable:
		return
	if bright_tween != null && bright_tween.is_running():
		bright_tween.kill()
	scale = Vector2(1.4,1.4)
	bright_tween = create_tween()
	bright_tween.tween_property(self,"scale",Vector2(1,1),0.5)

func unlock() -> void:
	collision_mask = 2
	if collecter is Player:
		collecter.hole_changed.disconnect(collected_player_enter_access)
	collecter = null
	follower = null
	state = CollectItem.STATE.IDLE
	is_collected = false

func collected_player_enter_access() -> void:
	var player : Player = collecter
	if hide_type == HIDE_TYPE.NONE:
		if player.current_hole != -1:
			hide_type = HIDE_TYPE.HOLE
			collect_hide()
		return
	elif hide_type == HIDE_TYPE.HOLE:
		if player.current_hole == -1:
			collect_show(player.global_position)
			hide_type = HIDE_TYPE.NONE

func _physics_process(delta: float) -> void:
	if is_collected && state == CollectItem.STATE.FOLLOW && follower != null :
		var dis := 40.0
		if follower is Charecter:
			navigation.target_position = follower.get_navigition_position()
			dis = follower.collect_item_follow_length
		elif follower is CollectItem:
			navigation.target_position = follower.global_position
			dis = follower.follow_length
		else:
			navigation.target_position = follower.global_position
		dis += follow_length
		
		var current_dis := navigation.distance_to_target()
		if current_dis > dis :
			if !navigation.is_navigation_finished():
				var next_point := navigation.get_next_path_position()
				var next_distance := next_point.distance_to(global_position)
				if next_distance < current_dis/10:
					move_and_collide(next_point - global_position)
				else:
					move_and_collide((next_point - global_position).normalized()*(current_dis/10))

func collect(player : Player) -> void:
	collision_mask = 0
	state = CollectItem.STATE.FOLLOW
	collecter = player
	is_collected = true
	
	if collecter is Player:
		collecter.hole_changed.connect(collected_player_enter_access)
