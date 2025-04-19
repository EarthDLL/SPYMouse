extends Node

var last_anima : Array[String] = []
@export var current_level : Level = null
@export var current_player : Player = null
@export var result_scene : PackedScene = null
@export var finished_label : PackedScene = null
@export var global_sounds : Dictionary = {}
@export var global_effects : Dictionary = {}
@onready var sound_player: SoundPlayer = $SoundPlayer
@onready var button: AudioStreamPlayer = $Button


#传入的位置是一个全局位置
func animaed_change_scene(scene : PackedScene , bg : String = "yellow", shape : String = "hole" , pos : Vector2 = Vector2.ZERO) -> void:
	last_anima = [bg , shape]
	await BgLayer.anima(MoveShape.anima.IN , bg , shape , pos , true , true)
	BgLayer.show_loading_text()
	await get_tree().change_scene_to_packed(scene)
	
#关于continue_anima:
#在animaed_change_scene执行后只播放了进场动画，这是因为无法获取出场动画的pos
#因此新场景可以调用try_anima播放出场动画，只需提供出场pos

func direct_change_scene(scene : PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)

func show_label(text : String , is_finished : bool = false) -> void:
	if is_instance_valid(current_level):
		var node := finished_label.instantiate()
		current_level.add_child(node)
		node.show_text(text , is_finished)
		node.finished.connect(node.queue_free)
		
func show_finish_label() -> void:
	show_label("Mission\nAccomplished!",true)

func global_pos_to_screen_pos(pos : Vector2) -> Vector2:
	return get_tree().get_root().canvas_transform.origin + pos
	
func screen_pos_to_global_pos(pos : Vector2) -> Vector2:
	return pos - get_tree().get_root().canvas_transform.origin

func play(id : String) -> void:
	sound_player.play_sound(id)

func button_sound() -> void:
	button.play()

func jump_to_level( id : int ) -> void:
	if Save.has_level(id):
		var info : LevelInfo = Save.get_level_info(id)
		if is_instance_valid(info):
			get_tree().change_scene_to_file(info.scene_path)
	

func get_global_effect(id : String) -> EffectTexture:
	if global_effects.has(id):
		return global_effects.get(id,null) as EffectTexture
	return null

func reset_db(music : float , sound : float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Sound"),
		linear_to_db(sound))
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music))
