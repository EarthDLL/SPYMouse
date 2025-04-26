extends Resource
class_name LevelInfo

@export var level_name : String = "Level"
@export var belong_world : int = 1
@export var level_id : int = 100
@export var level_index : String = "1-1"
@export var is_boss_level := false
@export var achievements : Array[Achievement]

@export var scene_path : String = ""
