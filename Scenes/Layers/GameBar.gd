extends CanvasLayer
class_name GameBar

@onready var holes: HBoxContainer = $Bar/CheeseBar/Holes
@onready var cheese_bar: Control = $Bar/CheeseBar
@onready var cheese_score: Control = $Bar/CheeseScore
@onready var texture: HBoxContainer = $Bar/CheeseBar/Texture
@onready var score: Label = $Bar/CheeseScore/Score
@onready var pause_btn: TextureButton = $Bar/Pause
var pause_bar : CanvasLayer
var is_game_paused := false

const pause_icon = preload("res://Resource/Hud/hud_paws.png")
const pause_over_icon = preload("res://Resource/Hud/hud_paws_over.png")
const continue_icon = preload("res://Resource/Hud/hud_play.png")
const continue_over_icon = preload("res://Resource/Hud/hud_play_over.png")

var max_count := 1
@export var cheese_icons : Array[Texture2D] = []

var anima : Tween = null
var current_score := 0 : 
	set(v):
		current_score = v
		if is_node_ready():
			score.text = str(current_score)
			
func show_pause_only() -> void:
	if is_node_ready() == false:
		await ready
	cheese_score.queue_free()
	cheese_bar.queue_free()
	#用于Boss关卡，只显示暂停界面

func set_cheese_max_count(count : int) -> void:
	if count <= 5:
		for i :int in count:
			if i < count:
				holes.get_child(i).show()
			else:
				holes.get_child(i).hide()
		texture.size.x = clampf(count * 38 + 50,56,1000)
		max_count = count

func _ready() -> void:
	BgLayer.black_screen_hide.connect(popup,4)
	cheese_score.position.y -= 65
	cheese_bar.position.y -= 65
	cheese_bar.modulate.a = 0.7
	cheese_score.modulate.a = 0.7
	
func popup() -> void:
	var tween := create_tween()
	tween.tween_property(cheese_bar,"position",Vector2(248,15),1.5)
	tween.parallel()
	tween.tween_property(cheese_score,"position",Vector2(40,15),1.5)
	
func popdown() -> void:
	var tween := create_tween()
	tween.tween_property(cheese_bar,"position",Vector2(248,-40),1.5)
	tween.parallel()
	tween.tween_property(cheese_score,"position",Vector2(40,-40),1.5)

func bright() -> void:
	if anima != null && anima.is_running():
		anima.kill()
	anima = create_tween()
	anima.tween_property(cheese_bar,"modulate",Color(1,1,1,0.9),0.3)
	anima.parallel().tween_property(cheese_score,"modulate",Color(1,1,1,0.9),0.3)
	anima.tween_interval(3)
	anima.tween_property(cheese_bar,"modulate",Color(1,1,1,0.7),0.3)
	anima.parallel().tween_property(cheese_score,"modulate",Color(1,1,1,0.7),0.3)
	

func set_score(new_score:int) -> void:
	var tween := create_tween()
	tween.tween_property(self,"current_score",new_score,0.3)
	bright()
	BgLayer.common_anima(score,false)
	
func update_items(items : Array[CollectItem]) -> void:
	if items.size() <= max_count:
		for i in max_count:
			holes.get_child(i).texture = cheese_icons[8]
		for i in items.size():
			if items[i] is Cheese:
				holes.get_child(i).texture = cheese_icons[items[i].type]
			elif items[i] is MouseToy:
				holes.get_child(i).texture = cheese_icons[6]
		bright()

func get_score_pos() -> Vector2:
	return Game.screen_pos_to_global_pos(%AnimaPos.global_position)


func _on_pause_pressed() -> void:
	if is_game_paused == true:
		is_game_paused = false
		if is_instance_valid(pause_bar):
			pause_bar.get_node("PauseBar")._on_continue_pressed()
			#PauseBar场景内部问题
		else:
			Game.current_level.contin()
			
		#修改按钮样式
		pause_btn.texture_normal = pause_icon
		pause_btn.texture_disabled = pause_icon
		pause_btn.texture_pressed = pause_over_icon
		pause_btn.texture_hover = pause_over_icon
	else:
		Game.current_level.pause()
		is_game_paused = true
		pause_bar = load("res://Scenes/UI/PauseBar.tscn").instantiate()
		add_child(pause_bar)
		Animations.pop(pause_bar,true)
	
		pause_btn.texture_normal = continue_icon
		pause_btn.texture_disabled = continue_icon
		pause_btn.texture_pressed = continue_over_icon
		pause_btn.texture_hover = continue_over_icon
