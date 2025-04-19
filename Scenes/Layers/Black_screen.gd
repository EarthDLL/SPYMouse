@tool
extends TextureRect

var is_poping := false
var tween : Tween = null

@onready var black_screen_texture: SubViewport = $BlackScreenTexture
@onready var screen_texture: Control = $BlackScreenTexture/Texture
@onready var level_name: Label = $"../LevelName"

func _ready() -> void:
	resized.connect(func():
		black_screen_texture.size = size
		screen_texture.queue_redraw()
	)

func popup(white_points : Array) -> void:
	if tween != null && tween.is_running():
		tween.kill()
	level_name.modulate = Color8(255,255,255,255)
	modulate = Color8(255,255,255,100)
	level_name.show()
	show()
	is_poping = true
	black_screen_texture.size = size
	screen_texture.points = white_points
	screen_texture.queue_redraw()
	await get_tree().create_timer(3).timeout
	if is_poping:
		start_hide()
	
func start_hide() -> void:
	get_parent().emit_signal("black_screen_hide")
	is_poping = false
	tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,0),2)
	tween.tween_property(level_name,"modulate",Color(1,1,1,0),2)
	await tween.finished
	hide()
	level_name.hide()
	
func hide_immediately() -> void:
	start_hide()
