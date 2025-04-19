extends Node

var world_paths := {}
var level_infos := {}
var levels_data_config := ConfigFile.new()
var game_settings := ConfigFile.new()

func get_worlds() -> void:
	var file := FileAccess.open("res://EngineResources/Worlds.json",FileAccess.READ)
	if is_instance_valid(file):
		var object := JSON.parse_string(file.get_as_text()) as Array
		for i in object:
			if i is Dictionary:
				world_paths[int(i.get("index",0))] = i.get("path","")
				
func get_levels() -> void:
	var file := FileAccess.open("res://EngineResources/Levels.json",FileAccess.READ)
	if is_instance_valid(file):
		var object := JSON.parse_string(file.get_as_text()) as Array
		for i in object:
			if i is Array && i.size() == 2:
				level_infos[int(i[0])] = i[1]

func _ready() -> void:
	read_levels_data()
	get_worlds()
	get_levels()
	load_settings()
	Game.reset_db(get_setting("Music",TYPE_FLOAT,1.0),get_setting("Sound",TYPE_FLOAT,1.0))

func get_setting(id : String , type : Variant.Type , defalut = 0):
	var value = game_settings.get_value("Settings",id , 0)
	if typeof(value) == type:
		return value
	return defalut
	
func set_setting(id : String , value) -> void:
	game_settings.set_value("Settings",id,value)
	save_settings()

func has_world_index(index : int) -> bool:
	if world_paths.has(index):
		return true
	return false

func has_level(id : int) -> bool:
	if level_infos.has(id):
		return true
	return false
	
func get_level_info(id : int) -> LevelInfo:
	var info := load(level_infos[id]) as LevelInfo
	return info
	
func read_levels_data() -> void:
	levels_data_config.load("user://LevelData.cfg")
		
func save_levels_data() -> void:
	levels_data_config.save("user://LevelData.cfg")
	
func load_settings() -> void:
	game_settings.load("user://Settings.cfg")
		
func save_settings() -> void:
	game_settings.save("user://Settings.cfg")


func get_level_achievement_state(level_id : int) -> Array:
	return levels_data_config.get_value(str(level_id),"Achievements",[])

func set_level_achievement_state(level_id : int , value : Array) -> void:
	levels_data_config.set_value(str(level_id),"Achievements",value)
	save_levels_data()
	
func finish_level(level_id : int) -> void:
	levels_data_config.set_value(str(level_id),"Finish",true)
	save_levels_data()
	
func is_finish_level(level_id : int) -> bool:
	return levels_data_config.get_value(str(level_id),"Finish",false)
