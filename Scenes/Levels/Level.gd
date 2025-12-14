extends Node
class_name Level

signal update_cheese_grayscale
signal continued
signal paused

@export var level_info : LevelInfo = null

@export var player : Player = null
@export var parts : Array[LevelPart] = []
@export var current_part : int = 0:
	set(value):
		if parts.size() != 0:
			if value >= parts.size():
				current_part = 0
			else:
				current_part = value
@export var doors : Array[Door] = []
@export var data : Data = null

@export_category("Time")
@export var time_min := 0
@export var time_max := 10
@export var max_time_score := 100

@onready var player_path : PlayerPath = $PlayerPath
@onready var sound: SoundPlayer = $Sound

var little_cheese_count := 0
var collected_little_cheese := 0
var is_item_collectable := true :
	set(v):
		is_item_collectable = v
		emit_signal("update_cheese_grayscale")

var effects : SpriteFrames = load("res://EngineResources/Effects/Level.tres")
var result_bar : CanvasLayer = null
var started := false
var point_score : int = 0 :
	set(v):
		point_score = v
		if game_bar != null:
			game_bar.set_score(point_score)
var game_bar : GameBar = null
var is_finished := false

func get_current_part() -> LevelPart:
	return parts[current_part]
			
func update_parts() -> void:
	for index in parts.size():
		if index == current_part:
			parts[index].show()
			parts[index].call_deferred("popup")
		else:
			parts[index].hide()
			parts[index].call_deferred("popdown")
			
func _enter_tree() -> void:
	Game.current_level = self
	
func update_cheese(count : int) -> void:
	get_current_part().update_cheese(count)
	game_bar.update_items(player.collected_items)
	
	if player.collected_items.size() >= player.collectable_items_count:
		is_item_collectable = false
	else:
		is_item_collectable = true
		
func pause() -> void:
	emit_signal("paused")
	set_process_mode(Node.PROCESS_MODE_DISABLED)

func contin() -> void:
	#继续，continue的缩写
	emit_signal("continued")
	set_process_mode(Node.PROCESS_MODE_INHERIT)

func _ready() -> void:
	
	game_bar = BgLayer.game_bar.instantiate()
	add_child(game_bar)
	
	Save.set_setting("last_played_level",level_info.level_id)
			
	game_bar.set_cheese_max_count(player.collectable_items_count)
	player.commit_cheeses.connect(commit_cheese)
	player.path = player_path
	player.update_cheese.connect(update_cheese)
	player.is_walking_changed.connect(data.update_timer)
	player.seeking_record.connect(player_seek_record)
	for cat : Node in get_tree().get_nodes_in_group("Cat"):
		if cat is Cat:
			cat.match_path()
	
	update_parts()
	if BgLayer.is_showing:
		BgLayer.try_anima(get_current_part().get_anima_point(),true)
	
	var player_positions : Array = [player.global_position]
	BgLayer.popup_black_screen(player_positions)
	BgLayer.set_level_name(level_info.level_name)
	
	if Save.get_setting("pecialModeCheeseTrap",1,false):
		add_child(SpecialModePickingWarn.new())
	if Save.get_setting("SpecialModeHiddenCat",1,false):
		add_child(SpecialModeHiddenCat.new())
	
func test_achievement() -> void:
	if result_bar != null:
		var history_record : Array = Save.get_level_achievement_state(level_info.level_id)
		for achievement in level_info.achievements:
			var result : bool = achievement.commit(data)
			if history_record.has(achievement.type):
				result = true
			elif result:
				history_record.append(achievement.type)
			result_bar.commit_achievement(achievement.type,achievement.get_description(),result)

		Save.set_level_achievement_state(level_info.level_id,history_record)
		if history_record.size() == level_info.achievements.size():
			Save.finish_level(level_info.level_id)

func fail(wait_time : float , anima_pos : Vector2) -> void:
	is_finished = true
	$BgMusic.stop()
	sound.play_sound("Die")
	await  get_tree().create_timer(wait_time).timeout
	BgLayer.anima(MoveShape.anima.IN,"purple","cat",anima_pos,true,true)
	await BgLayer.anima_finsished
	if is_instance_valid(level_info):
		if Save.has_level(level_info.level_id):
			Game.jump_to_level(level_info.level_id)
			return
		elif Save.has_world_index(level_info.belong_world):
			get_tree().change_scene_to_file(Save.world_paths[level_info.belong_world])
			return
	get_tree().change_scene_to_file(Save.world_paths[1])
	
func complete() ->void:
	is_finished = true
	data.finish()
	Game.show_finish_label()
	$BgMusic.stop()
	sound.play_global_sound("Finish")

	await get_tree().create_timer(2).timeout
	result_bar = Game.result_scene.instantiate()
	add_child(result_bar)
	data.set_score(get_time_score() + point_score)
	result_bar.commit_level_id(level_info.level_id)
	result_bar.commit_info(level_info.level_index,level_info.level_name)
	result_bar.commit_data(point_score,get_time_score(),data.get_used_time())
	result_bar.commit_map(level_info.belong_world)
	test_achievement()
	
func get_time_score() -> int:
	var time := data.get_used_time()
	if time <= 0:
		return 0
	elif time >= time_max:
		return 0
	elif time <= time_min:
		return max_time_score
	else:
		return roundi(max_time_score * (1 - (time - time_min) / (time_max - time_min)))

func add_score_after_commiting(type : Player.COMMITTYPE) -> void:
	var score : int = 0
	for cheese : Cheese in player.get_collected_cheeses():
		score += cheese.single_score
	match type:
		Player.COMMITTYPE.DOOR:
			score = score * 2
	add_score(score)

func commit_cheese(type : Player.COMMITTYPE) -> void:
	add_score_after_commiting(type)
	if type == Player.COMMITTYPE.FREE:
		for item : CollectItem in player.collected_items:
			if item is Cheese:
				item.queue_free()
	player.clear_all_cheese()
	game_bar.update_items(player.collected_items)

func start() -> void:
	data.start()
	started = true

#存档点机制
func save_level() -> Dictionary:
	var info := {}
	for player in get_tree().get_nodes_in_group("Player"):
		if player is Player:
			info[str(get_path_to(player))] = player.get_game_info()
	return info
			
func restore_level(info : Dictionary) -> void:
	pass
	
func player_seek_record() -> void:
	if !started:
		start()
	data.total_paths += 1

func add_score(count :int) -> void:
	point_score += count
	game_bar.set_score(point_score)

func show_sprite(pos : Vector2 , effect_id : String , time : float) -> void:
	var part : Node
	if self is BossLevel:
		part = self
	else:
		part = get_current_part()
	var node := AnimatedSprite2D.new()
	node.global_position = pos
	node.sprite_frames = effects
	node.z_index = 80
	node.z_as_relative = false
	part.add_child(node)
	node.play(effect_id)
	get_tree().create_timer(time).timeout.connect(Callable(node,"queue_free"))

func jump_to_part(part : int) -> void:
	var pos := player.global_position
	sound.play_sound("JumpPart")
	BgLayer.anima(MoveShape.anima.IN,"yellow","star",pos,true,true)
	await BgLayer.anima_finsished
	current_part = part
	update_parts()
	var target_part := get_current_part()
	player.access_enter_finished()
	player.reparent(target_part,true)
	player.clear_state()
	var new_pos := Vector2.ZERO
	if is_instance_valid(target_part.spawn_point):
		new_pos = target_part.spawn_point.global_position
	player.global_position = new_pos
	for item : CollectItem in player.collected_items:
		item.reparent(get_current_part(),true)
		item.collect_show(player.global_position)
	
	
	BgLayer.try_anima(player.global_position)
