extends Level
class_name BossLevel

@export var signaler : VisibleOnScreenNotifier2D = null
@export var camera : Camera2D = null

@export var respawner : BossLevelRespawner = null

@onready var fail_effect: Node2D = $FailEffect
var boss_cat : BossCat
var restore_index := -1


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
		signaler.screen_exited.connect(Callable(self,"fail").bind(0.1,player.global_position))
	for cat : Cat in get_tree().get_nodes_in_group("Cat"):
		if is_instance_valid(cat) && cat is BossCat:
			boss_cat = cat
			cat.fail.connect(fail_by_checked)
			
	if Game.last_level_point_id == level_info.level_id:
		print("yes")
		restore_level(Game.get_level_cache())
	Game.last_level_point_id = -1
			
	#等待一会再检测
	await get_tree().create_timer(0.5).timeout
	signaler.visible = true
	boss_cat.is_started = true
func restore_level(info : Dictionary) -> void:
	if info.get("index" , -1) > -1:
		player.global_position = respawner.player_respawn_pos[info.index]
		boss_cat.global_position = boss_cat.path.get_point_position(respawner.cat_respawn_index[info.index])
		boss_cat.current_path_index = respawner.cat_respawn_index[info.index]
func save_level() -> Dictionary:
	return {
		"level_id" : level_info.level_id,
		"index" : restore_index
	}
	
func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 30 == 0 && is_finished == false:
		if respawner.store_x_vectors.size() > restore_index + 1:
			var index := restore_index +1
			if player.global_position.x >= respawner.store_x_vectors[index]:
				restore_index += 1
	
func fail_by_checked() -> void:
	player.path.clear_all_points()
	process_mode = Node.PROCESS_MODE_DISABLED
	fail(3.0,player.global_position)
	if restore_index > -1:
		Game.save_level_cache(save_level())
	if is_instance_valid(boss_cat):
		fail_effect.start(boss_cat.global_position,player.global_position)
