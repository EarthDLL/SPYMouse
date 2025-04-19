extends CanvasLayer

signal anima_finsished
signal black_screen_hide

@onready var move_shape: MoveShape = $ShapeLayer/MoveShape
@onready var move_bg: MoveBg = $ShapeLayer/MoveShape/MoveBg
@onready var loading_text: Label = $ShapeLayer/MoveShape/Loading
@onready var black_screen: TextureRect = $BlackScreen
var game_bar : PackedScene = load("res://Scenes/Layers/GameBar.tscn")

@export var is_showing : bool = false

var bg_type := {
	"yellow" : "uid://hxwok4p877fb",
	"purple" : "uid://lh4fqflmviry",
	"blue" : "uid://cm262jkyvvwht",
}

#BGshape名 : [ texture路径 , 能挡住全屏的size ]
var bg_shape := {
	"cat" : ["uid://cy4c20e8xee4" , 6 ],
	"hole" : ["uid://do5vsbxr105qp" , 5 ],
	"star" : ["uid://dx17gwv3d48c0" , 8 ],
	"tonsill" : ["uid://dykg57qluvpvq" , 10 ],
	"mouse" : ["uid://daxiqyuc1kcor" , 12.5]
}

var anima_time : float = 1.2
var last_anima_data := []
#var shape_max_size : float = 10

func try_anima(pos : Vector2 , tran : bool = true, keep_pos : bool = false) -> void:
	#如果Keep_pos为True，将不使用传入的pos，而是套用进入时的pos
	if last_anima_data.size() != 0:
		if keep_pos:
			pos = last_anima_data[2]
			tran = last_anima_data[3]
		anima(MoveShape.anima.OUT,last_anima_data[0],last_anima_data[1],pos,tran)
		last_anima_data = []

func anima(type : MoveShape.anima , bg :String , shape :String , pos : Vector2 , tran : bool = true , prepare : bool = false) -> void:
	if !bg_type.has(bg) || !bg_shape.has(shape):
		print("MoveBG Can not Find TYPE or SHAPE!")
		emit_signal("anima_finsished")
		return
	if prepare:
		last_anima_data = [bg,shape,pos,tran]
	else:
		last_anima_data = []
	move_shape.shape = load(bg_shape[shape][0])
	move_bg.bg_pic = load(bg_type[bg])
	if tran:
		move_shape.point = Game.global_pos_to_screen_pos(pos)
	else:
		move_shape.point = pos
#	print(pos)
#	print(get_tree().get_root().canvas_transform)
	
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	match type:
		MoveShape.anima.OUT:
			is_showing = false
			move_shape.shape_size = 0
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(move_shape,"shape_size",bg_shape[shape][1],anima_time)
			await tween.finished
			move_shape.hide()
			hide_loading_text()
			emit_signal("anima_finsished")
		MoveShape.anima.IN:
			is_showing = true
			move_shape.show()
			move_shape.shape_size = bg_shape[shape][1]
			tween.set_ease(Tween.EASE_OUT)
			var timer = get_tree().create_timer(1.0)
			tween.tween_property(move_shape,"shape_size",0,anima_time)
			await timer.timeout
			await tween.finished
			emit_signal("anima_finsished")
	
func show_loading_text() -> void:
	loading_text.show()
	
func hide_loading_text() -> void:
	loading_text.hide()
	
func popup_black_screen(white_points : Array) -> void:
	black_screen.popup(white_points)

func hide_black_screen() ->void:
	black_screen.hide_immediately()

func is_black_screen_poping() -> bool:
	return black_screen.is_poping

func set_level_name(string : String) -> void:
	$LevelName.text = string

func common_anima(object : Node , scale : bool = false) -> void:
	if object is Control:
		object.pivot_offset = object.size/2
	var tween := create_tween()
	object.show()
	if scale:
		object.scale = Vector2(0.3,0.3)
		tween.tween_property(object,"scale",Vector2(1,1),0.15)
	tween.tween_property(object,"scale",Vector2(0.7,1),0.08)
	tween.tween_property(object,"scale",Vector2(1,0.7),0.08)
	tween.tween_property(object,"scale",Vector2(1,1),0.04)
