@tool
extends CollectItem
class_name MouseToy

enum Side{
	UP,
	LEFT,
	DOWN,
	RIGHT
}

@export var side : MouseToy.Side = Side.UP :
	set(value):
		side = value
		if is_node_ready():
			update_side()

var textures := [
	load("uid://68qwq58ub46t"),
	load("uid://uwxjgovpr6yr"),
	load("uid://cgf00rpb50cb6"),
	load("uid://ocvqu0845ks1"),
	load("uid://bcqqkkeona5gd"),
	load("uid://kqygifeumh34"),
	load("uid://csdyeq8bmcpuh"),
	load("uid://c6chwoqwrjrra"),
	load("uid://qq5i6cju2pi4"),
]

func update_side() -> void:
	match side:
		Side.UP:
			sprite.texture = textures[0]
			sprite.flip_h = false
		Side.LEFT:
			sprite.texture = textures[4]
			sprite.flip_h = false
		Side.DOWN:
			sprite.texture = textures[8]
			sprite.flip_h = false
		Side.RIGHT:
			sprite.texture = textures[4]
			sprite.flip_h = true

func _ready() -> void:
	update_side()

func _physics_process(delta: float) -> void:
	super(delta)
	if state == CollectItem.STATE.FOLLOW && collecter != null:
		if Engine.get_physics_frames() % 20 == 0:
			sprite.frame = (sprite.frame+1)%4
		if Engine.get_physics_frames() % 3 == 0:
			var angle := float(int((navigation.target_position - global_position).angle()/(PI/16)))/2
			if angle < 0:
				angle = 0 - floorf(angle)
			elif angle > 0:
				angle = 16 - ceilf(angle)
			angle -= 4
			if angle < 0:
				angle = 16 + angle
			if angle <= 8:
				sprite.texture = textures[angle]
				sprite.flip_h = false
			else:
				sprite.texture = textures[16-angle]
				sprite.flip_h = true
