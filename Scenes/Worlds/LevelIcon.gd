extends Sprite2D
class_name LevelIcon

enum TYPE {
	LEVEL,
	BOSS,
	NEXT,
	FORWARD,
}

enum BTN_DIRECTION{
	LEFT_DOWN,
	LEFT_UP,
	RIGHT_DOWN,
	RIGHT_UP
}

@export var collect_rect := Rect2(-25,-25,50,50)
@export var building : Node2D = null
@export var type : TYPE = TYPE.LEVEL
@export var play_btn_direction : BTN_DIRECTION = BTN_DIRECTION.LEFT_UP
@export var level_id : int = 100
@export var line_index : int = -1
var has_light := false

func _enter_tree() -> void:
	z_index = 2
