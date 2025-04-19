extends CanvasLayer

# 数字是Achievement.TYPE的值，负数代表未完成
const achievement_icons = {
	3 : "uid://gemxui0cshbr",
	-3 : "uid://cvungvmkof4lc",
	1 : "uid://cc5kk77fxmcts",
	-1 : "uid://coyo4ro5qvf2n",
	2 : "uid://cvuab0i71pupc",
	-2 : "uid://cj4c7cyvljf21",
	4 : "uid://daxxudeqikwpm",
	-4 : "uid://cf0qu3wxd444t",
	5 : "uid://c8v471hbwo5up",
	-5 : "uid://dlptbt86qkshs",
	6 : "uid://csku0dtvn7cu5",
	-6 : "uid://tm82kt3l5qkp",
}
@onready var result: Control = $Result
@onready var panel: TextureRect = $Result/Panel
@onready var next: TextureButton = $Result/Panel/Next
@onready var replay: TextureButton = $Result/Panel/Replay
var index := 0
@onready var achievements: HBoxContainer = $Result/Panel/Achievements
@onready var counting_sound: AudioStreamPlayer = $Counting

var current_point_score := 0
var current_time_score := 0

func show_popup_anima(object : Control) -> void:
	BgLayer.common_anima(object,true)

func popup() -> void:
	BgLayer.anima(MoveShape.anima.IN,"yellow","hole",result.size/2,false,true)
	show_popup_anima(panel)
	await get_tree().create_timer(1.2).timeout
	show_popup_anima(next)
	show_popup_anima(replay)
	show_popup_anima($Result/DataBtn)
	
func _ready() -> void:
	panel.hide()
	next.hide()
	replay.hide()
	await get_tree().create_timer(1).timeout
	update_achievement_label()
	popup()

func commit_info(level_index : String , level_name : String ) -> void:
	$Result/Panel/Title.text = level_index + "\n" + level_name
	
func commit_data(point_score : int , time_score : int , time : float) -> void:
	$Result/Panel/Time.text = "(" + str((int(time) - int(time)%60)/60) + "m " + str(int(time)%60) + "s)"
	await  get_tree().create_timer(1).timeout
	counting_sound.play()
	var tween := create_tween()
	tween.tween_property(self,"current_point_score",point_score,2)
	tween.parallel().tween_property(self,"current_time_score",time_score,2)
	await tween.finished
	counting_sound.stop()
	
func commit_level_id(id : int) -> void:
	%Replay.pressed.connect(func():
		Game.button_sound()
		if Save.has_level(id):
			await popdown()
			Game.jump_to_level(id)
		)
	
func commit_achievement(type : Achievement.TYPE , des : String , result : bool) -> void:

	if !achievement_icons.has(type) :
		return
	if index <= 2:
		var rect : TextureRect = achievements.get_child(index)
		rect.texture = load(achievement_icons.get(type if result else -type))
		rect.show()
		rect.description = des
		rect.type = type
		rect.pressed.connect(popup_achievement_label)
		index += 1
		
func commit_map(index : int) -> void:
	next.pressed.connect(func():
		Game.button_sound()
		if Save.has_world_index(index):
			await popdown()
			get_tree().change_scene_to_file(Save.world_paths[index])
		)
		
func _physics_process(delta: float) -> void:
	$Result/Panel/Point.text = str(current_point_score)
	$Result/Panel/TimeScore.text = str(current_time_score)
	$Result/Panel/Total.text = str(current_time_score + current_point_score)

func set_achievement_label(texture : Texture2D,text : String) -> void:
	%Label.text = text
	$Result/Panel/Show/Label/Icon.texture = texture
	update_achievement_label()
	
func popup_achievement_label(type : Achievement.TYPE , text : String) -> void:
	set_achievement_label(load(achievement_icons.get(type)),text)
	show_achievement_label()

func show_achievement_label()->void:
	%Show.show()

func update_achievement_label() -> void:
	$Result/Panel/Show.size = %Label.size
	%Show.size.x += 50
	%Show.position.x = ( panel.size.x - %Show.size.x )/2 + 20

func popdown() -> void:
	var tween := create_tween()
	tween.tween_property(panel,"scale",Vector2(0,0),0.3)
	await tween.finished

func _on_data_btn_pressed() -> void:
	var bar := load("res://Scenes/UI/TextBar.tscn").instantiate() as TextBar
	add_child(bar)
	bar.z_index = 101
	bar.set_title("数据")
	var data : Data = Game.current_level.data
	var text := str("游戏时间:",int(data.get_used_time()),"s\n")
	text += str("总路径数:",data.total_paths)
	text += str("\n被发现次数:",data.found_time)
	text += str("\n猫撞墙次数:",data.stupid_cat_crash_count)
	bar.set_text(text)
	bar.popup()
