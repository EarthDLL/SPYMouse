extends Control



func _ready() -> void:
	if is_instance_valid(Game.current_level) && is_instance_valid(Game.current_level.level_info):
		var info : LevelInfo = Game.current_level.level_info
		%Index.text = info.level_index
		%Name.text = info.level_name
		if info.is_boss_level:
			%BossIcon.show()

func _on_quit_pressed() -> void:
	await BgLayer.anima(MoveShape.anima.IN,"blue","hole",Vector2(0,0),true,true)
	if is_instance_valid(Game.current_level) && is_instance_valid(Game.current_level.level_info):
		if Save.has_world_index(Game.current_level.level_info.belong_world):
			get_tree().change_scene_to_file(Save.world_paths[Game.current_level.level_info.belong_world])
			return
		get_tree().change_scene_to_file("res://Scenes/Start/Start.tscn")


func _on_reload_pressed() -> void:
	BgLayer.anima(MoveShape.anima.IN,"blue","hole",Vector2(0,0),true,true)
	await  BgLayer.anima_finsished
	if is_instance_valid(Game.current_level) && is_instance_valid(Game.current_level.level_info):
		var level_id : int = Game.current_level.level_info.level_id
		if Save.has_level(level_id):
			Game.jump_to_level(level_id)
			return
		if Save.has_world_index(Game.current_level.level_info.belong_world):
			get_tree().change_scene_to_file(Save.world_paths[Game.current_level.level_info.belong_world])
			return
	get_tree().change_scene_to_file("res://Scenes/Start/Start.tscn")

func _on_continue_pressed() -> void:
	Game.button_sound()
	Animations.pop(self,false)
	await get_tree().create_timer(0.2).timeout
	queue_free()
	Game.current_level.contin()
