@tool
extends Node2D
class_name LevelPart

@export var cheese_count := 0
@export var is_hidden := false
@export var camera : Camera2D
@export var anima_point: Node2D = null
@export var access_nodes : Array[AccessNode] = []
@export var spawn_point : Node2D = null
@onready var region: NavigationRegion2D = $Region

func popup() -> void:
	region.enabled = true
	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	if is_hidden:
		Game.show_label("隐藏区域！")
		is_hidden = false
	
func popdown() -> void:
	region.enabled = false
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

func get_anima_point() -> Vector2:
	if anima_point != null:
		return anima_point.global_position
	else:
		return global_position
		
func update_cheese(count : int) -> void:
	if count >= cheese_count:
		for node : AccessNode in  access_nodes:
			node.access_open()
