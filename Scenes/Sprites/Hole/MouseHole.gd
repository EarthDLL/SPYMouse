@tool
extends Area2D
class_name MouseHole

enum COLOR{
	YELLOW,
	PURPLE,
	GREEN,
	ORANGE,
	RED,
	GRAY,
	BLUE
}

enum DIRECTION{
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3
}

const leave_offest = [
	Vector2(0,-30),
	Vector2(0,26),
	Vector2(-26,0),
	Vector2(26,0),
]
#TODO 左右方向的位置未测试
const touch_rect := Rect2(-20,-30,40,60)
const colors = [
	Color8(255,221,0),
	Color8(196,56,193),
	Color8(58,171,28),
	Color8(255,131,0),
	Color8(220,36,16),
	Color8(108,107,109),
	Color8(19,94,227)
]
var tween : Tween = null
var is_lighting := false
@onready var sprite: Sprite2D = $Sprite
@onready var light: Sprite2D = $Light
@onready var sound_player: SoundPlayer = $SoundPlayer
@onready var item_point: Node2D = $ItemPoint

@export var direction : DIRECTION = DIRECTION.DOWN
@export var color : COLOR = COLOR.YELLOW:
	set(value):
		color = value
		update_color()
			
func _unhandled_input(event: InputEvent) -> void:
	if !is_lighting:
		return
	if event is InputEventScreenTouch && event.is_pressed():
		if touch_rect.has_point(make_input_local(event).position):
			var player : Player = Game.current_player
			player.leave_hole(leave_offest[direction] + global_position)
			sound_player.play_sound("Exit")
			player.path.player_seek_record(event.index,player.global_position)

func update_color() -> void:
	if is_instance_valid(sprite):
		sprite.self_modulate = colors[color]

func update() -> void:
	var type : int = Game.current_player.current_hole
	if type == color && !is_lighting:
		is_lighting = true
		light.show()
		shine_light()
	if type != color:
		is_lighting = false
		light.hide()
		if is_instance_valid(tween):
			tween.kill()

func shine_light() -> void:
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	light.scale = Vector2(0.75,0.75)
	tween.tween_property(light,"scale",Vector2(1.2,1.2),0.45)
	tween.tween_property(light,"scale",Vector2(0.75,0.75),0.45)
	tween.finished.connect(shine_light)

func _ready() -> void:
	if !Engine.is_editor_hint():
		Game.current_player.hole_changed.connect(update)
	update_color()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.state == Player.State.WALK:
			body.enter_hole(color,global_position,item_point.global_position)
			sound_player.play_sound("Enter")
	elif body.is_in_group("TestBody"):
		if !get_overlapping_bodies().has(Game.current_player):
			var path := body.get_parent() as PlayerPath
			path.enter_hole(self)
