extends Cat
class_name StupidCat

##猫冲撞后判断是否撞墙的距离，与碰撞箱保持一致
const shoot_crash_range = 24.0
const shoot_distance = 90.0

@onready var view: RayCast2D = $View
@onready var navigation: NavigationAgent2D = $Navigation
@onready var catch_area: Area2D = $CatchArea
@onready var collision: CollisionShape2D = $CatchArea/Collision

@onready var sleep_particle: CPUParticles2D = $Particle

var last_sleep_spot : SleepSpot = null
var is_sleeping := false
var next_sleep_time := 0
var shoot_type := SHOOT_STEP.AIM
enum SHOOT_STEP{
	AIM,
	SHOOT,
	ANIMA
}

var textures := [
	load("res://Resource/sprites/browncat01.png"),
	load("res://Resource/sprites/browncat02.png"),
	load("res://Resource/sprites/browncat03.png"),
	load("res://Resource/sprites/browncat04.png"),
	load("res://Resource/sprites/browncat05.png"),
	load("res://Resource/sprites/browncat_common.png"),
	load("res://Resource/sprites/browncat_idle01.png"),
	load("res://Resource/sprites/browncat_idle02.png"),
	load("res://Resource/sprites/browncat_idle03.png"),
	load("res://Resource/sprites/browncat_idle04.png"),
	load("res://Resource/sprites/browncat_idle05.png"),
	load("res://Resource/sprites/browncat_rotate.png"),
	load("res://Resource/sprites/browncat_string.png"),
]

var frames_count : Array[Vector2i] = [
	Vector2i(10,1),
	Vector2i(10,1),
	Vector2i(10,1),
	Vector2i(10,1),
	Vector2i(10,1),
	Vector2i(14,1),
	Vector2i(15,1),
	Vector2i(15,1),
	Vector2i(15,1),
	Vector2i(15,1),
	Vector2i(15,1),
	Vector2i(8,1),
	Vector2i(8,2),
]


func set_texture(index : int) -> void:
	sprite.texture = textures[index]
	sprite.hframes = frames_count[index].x
	sprite.vframes = frames_count[index].y

func _ready() -> void:
	pass
	
func check_target() -> void:
	if target == null && is_target_in_view:
		is_target_in_view = false
		lose_target()
	
func scan_player() -> void:
	var ray_player : Player = null
	var ray_distance : float = 0.0
	var player = Game.current_player
	if is_instance_valid(player) && player.is_active():
		view.target_position = to_local(player.global_position)
		view.force_raycast_update()
		if !view.is_colliding():
			var angle := view_direction_vector.angle_to(to_local(player.global_position))
			if angle > -1.308 && angle < 1.308:
				var dis := global_position.distance_squared_to(player.global_position)
				if ray_player == null || dis < ray_distance:
					ray_player = player
					ray_distance = dis
	update_target(ray_player)
	
var shoot_dir := Vector2.ZERO
var shoot_speed := 50
func shoot() -> void:
	state = STATE.SHOOT
	shoot_type = SHOOT_STEP.AIM
	sound_player.play_sound("Aim")
	set_direction_by_vector2(shoot_dir)
	play_direction_anima(view_direction,"Found")
	show_sign(1,Vector2(0,-60),0.9)
	sound_player.play_sound("Aim")
	await get_tree().create_timer(0.8).timeout
	play_direction_anima(view_direction,"Walk")
	shoot_type = SHOOT_STEP.SHOOT
	sound_player.play_sound("Shoot")
	
	shoot_speed = 250
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self,"shoot_speed",380,0.1)
	tween.tween_interval(0.2)
	tween.tween_property(self,"shoot_speed",250,0.1)
	
	await  get_tree().create_timer(0.4).timeout
	final_target_position = global_position
	crash_test()
		
func crash_test() -> void:
	if is_on_wall():
		view.target_position = view_direction_vector.normalized() * shoot_crash_range + collision.position
		view.force_raycast_update()
		if view.is_colliding():
			Game.current_level.data.stupid_cat_crash_count += 1
			sound_player.play_sound("Crash")
			shoot_type = SHOOT_STEP.ANIMA
			play_direction_anima(view_direction,"Stun")
			get_tree().create_timer(1.5).timeout.connect(func():
				sound_player.play_sound("Stun"))
			await anima.animation_finished
			state = STATE.CHASING
		else:
			state = STATE.CHASING
	else:
		state = STATE.CHASING
		
func is_active() -> bool:
	if state == STATE.SLEEP:
		return false
	return true
	
func next_path_point() -> void:
	var test := is_path_back
	super()
	if path.is_loop:
		if test != is_path_back:
			last_sleep_spot = null
	else:
		if current_path_index == 0:
			last_sleep_spot = null
		
func sleep(spot : SleepSpot) -> void:
	if last_sleep_spot == spot:
		return
	state = STATE.SLEEP
	navigation.target_position = spot.global_position
	next_sleep_time = spot.sleep_time
	last_sleep_spot = spot
	
func wake_up() -> void:
	next_sleep_time = 0
	sleep_particle.emitting = false
	sound_player.play_sound("SleepEnd")
	anima.play("Awake")
	await anima.animation_finished
	state = STATE.IDLE
	is_sleeping = false

func _physics_process(delta: float) -> void:

	check_target()
	
	if state == STATE.SLEEP && next_sleep_time != 0.0:
		if !is_sleeping:
			if !navigation.is_navigation_finished():
				var direction := navigation.get_next_path_position() - global_position
				move_and_collide(direction.normalized() * get_speed())
			else:
				is_sleeping = true
				anima.play("Sleep")
				anima.queue("Sleeping")
				sound_player.play_sound("Sleep")
				sleep_particle.emitting = true
				get_tree().create_timer(next_sleep_time - anima.get_animation("Sleep").length).timeout.connect(wake_up)
	
	if state == STATE.CHASING && is_target_in_view:
		if target.global_position.distance_to(global_position) <= shoot_distance:
			shoot_dir = (target.global_position - global_position).normalized()
			shoot()
			
	if state == STATE.SHOOT:
		if shoot_type == SHOOT_STEP.SHOOT:
			velocity = shoot_dir * shoot_speed
			move_and_slide()
	
	if state == STATE.CHASING:
		if is_target_in_view:
			navigation.target_position = target.global_position
		else:
			navigation.target_position = final_target_position
			eye.show()
		if !navigation.is_navigation_finished():
			var direction := navigation.get_next_path_position() - global_position
			move_and_collide(direction.normalized() * get_speed())
			set_direction_by_vector2(direction)
			play_direction_anima(view_direction,"Walk")
		else:
			if !is_target_in_view:
				lose_target()
	
	if state == STATE.BACK:
		navigation.target_position = back_point
		if !navigation.is_navigation_finished():
			var direction := navigation.get_next_path_position() - global_position
			move_and_collide(direction.normalized() * get_speed())
			set_direction_by_vector2(direction)
			play_direction_anima(view_direction,"Walk")
		else:
			state = STATE.IDLE
	
	if state == STATE.IDLE || state == STATE.WALK:
		var direction := follow_path()
		if direction != Vector2():
			set_direction_by_vector2(direction)
			play_direction_anima(view_direction,"Walk")
	
	if Engine.get_physics_frames() % 6 == 0:
		if is_active():
			scan_player()
	
	if is_active():
		for body : Node2D in catch_area.get_overlapping_bodies():
			if body is Player:
				if body.is_active():
					body.be_catched(CATCH_TYPE.CATCH)
					sound_player.play_sound("Fight")
					hide()
					set_physics_process(false)
