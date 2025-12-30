extends Level
class_name LevelFinal

func _ready() -> void:
	game_bar = null
	
	player.commit_cheeses.connect(commit_cheese)
	player.path = player_path
	player.update_cheese.connect(update_cheese)
	player.is_walking_changed.connect(data.update_timer)
	player.seeking_record.connect(player_seek_record)
	for cat : Node in get_tree().get_nodes_in_group("Cat"):
		if cat is Cat:
			cat.match_path()
			
	if BgLayer.is_showing:
		BgLayer.try_anima(get_current_part().get_anima_point(),true)
		
	
func test_achievement() -> void:
	return 
	
func fail(wait_time : float , anima_pos : Vector2) -> void:
	return
	# TODO
	
func complete() ->void:
	pass
	
func get_time_score() -> int:
	return 0
	
