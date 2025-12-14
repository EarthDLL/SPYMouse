extends Level
class_name BossLevel

enum CheeseCommitType{
	NORMAL, #像普通关卡一样
	FREE #捡到立刻删除
}

@export var signaler : VisibleOnScreenNotifier2D = null
@export var camera : Camera2D = null
@export var entrance_area : Area2D = null
@export var respawner : BossLevelRespawner = null
@export var commit_type : CheeseCommitType = 0
@onready var fail_effect: Node2D = $FailEffect
var boss_cat : BossCat
var restore_index := -1
var entrance_able := false

func _ready() -> void:
	camera.reset_smoothing()
	camera.force_update_scroll()
	player.path = player_path
	
	game_bar = BgLayer.game_bar.instantiate()
	game_bar.show_pause_only()
	add_child(game_bar)
	
	player.update_cheese.connect(update_cheese)
	player.is_walking_changed.connect(data.update_timer)
	for cat : Node in get_tree().get_nodes_in_group("Cat"):
		if cat is Cat:
			cat.match_path()
	
	if is_instance_valid(respawner) == false:
		respawner = BossLevelRespawner.new()
	
	Save.set_setting("last_played_level",level_info.level_id)
	if BgLayer.is_showing:
		BgLayer.try_anima(player.global_position,true)
	
	if is_instance_valid(signaler):
		signaler.screen_exited.connect(Callable(self,"out_of_screen"))
		signaler.screen_entered.connect(Callable(self,"enter_screen"))
	for cat : Cat in get_tree().get_nodes_in_group("Cat"):
		if is_instance_valid(cat) && cat is BossCat:
			boss_cat = cat
			cat.fail.connect(fail_by_checked)
	if is_instance_valid(boss_cat):
		boss_cat.complete_path.connect(Callable(self,"cat_path_complete"))
			
	if Game.last_level_point_id == level_info.level_id:
		restore_level(Game.get_level_cache())
	Game.last_level_point_id = -1
	
	if is_instance_valid(entrance_area):
		entrance_area.body_entered.connect(Callable(self,"entrance_entered"))
			
	#等待一会再检测
	await get_tree().create_timer(0.5).timeout
	signaler.visible = true
	boss_cat.is_started = true
func restore_level(info : Dictionary) -> void:
	if info.get("index" , -1) > -1:
		player.global_position = respawner.player_respawn_pos[info.index]
		boss_cat.global_position = boss_cat.path.get_point_position(respawner.cat_respawn_index[info.index])
		boss_cat.current_path_index = respawner.cat_respawn_index[info.index]
		restore_index = info.index
		
func save_level() -> Dictionary:
	return {
		"level_id" : level_info.level_id,
		"index" : restore_index
	}
	
func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 30 == 0 && is_finished == false:
		if respawner.store_x_vectors.size() > restore_index + 1:
			var index := restore_index + 1
			if player.global_position.x >= respawner.store_x_vectors[index]:
				restore_index += 1
				
func fail(wait_time : float , anima_pos : Vector2) -> void:
	if restore_index > -1:
		Game.save_level_cache(save_level())
	super(wait_time , anima_pos)
	
func fail_by_checked() -> void:
	player.path.clear_all_points()
	process_mode = Node.PROCESS_MODE_DISABLED
	fail(3.0,player.global_position)
	if is_instance_valid(boss_cat):
		fail_effect.start(boss_cat.global_position,player.global_position)

func out_of_screen() -> void:
	player.state = Player.State.PUSHED
	player.path.clear_all_points()
	
func enter_screen() -> void:
	if player.state == Player.State.PUSHED:
		player.state = Player.State.IDLE

func add_score(score : int) -> void:
	pass

func complete() ->void:
	#TODO:补充
	pass
	
func commit_cheese(type : Player.COMMITTYPE) -> void:
	if type == Player.COMMITTYPE.FREE:
		for item : CollectItem in player.collected_items:
			if item is Cheese:
				item.queue_free()
	player.clear_all_cheese()

func cat_path_complete() -> void:
	print("complete")
	boss_cat.queue_free()
	entrance_able = true
	
func entrance_entered(body : Node2D) -> void:
	if body is Player:
		player.state = Player.State.BOSS_ANIMA
		player.collision_layer = 0
	entrance_area.call_deferred("set_monitoring",false)

func update_cheese(count : int) -> void:
	is_item_collectable = true
	if count > 0:
		commit_cheese(Player.COMMITTYPE.FREE)
