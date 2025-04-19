extends CollectItem
class_name Cheese

#隐藏的类型

@export var single_score : int = 10
@export var type : int = 0
@export var get_effect: Sprite2D = null

var gray_scale_material : ShaderMaterial = load("res://EngineResources/Shaders/GrayScaleMaterial.tres")


func _physics_process(delta: float) -> void:
	super(delta)
	if state == CollectItem.STATE.FOLLOW && collecter != null:
		if Engine.get_physics_frames() % 3 == 0:
			var angle := float(int((navigation.target_position - global_position).angle()/(PI/16)))/2
			if angle < 0:
				angle = 0 - floorf(angle)
			elif angle > 0:
				angle = 16 - ceilf(angle)
			angle -= 1
			if angle < 0:
				angle = 16 + angle
			if int(angle) != sprite.frame:
				sprite.frame = angle

func collect(player : Player) -> void:
	super(player)
	update_sprite_color()
	get_effect.show()
	var tween := create_tween()
	tween.tween_property(get_effect,"frame",4,0.2)
	await tween.finished
	get_effect.hide()
	
func _ready() -> void:
	Game.current_level.update_cheese_grayscale.connect(update_sprite_color)
	
func unlock() -> void:
	super()
	update_sprite_color()

func update_sprite_color() -> void:
	if is_collected || Game.current_level.is_finished:
		sprite.material = null
	else:
		if Game.current_level.is_item_collectable:
			sprite.material = null
		else:
			sprite.material = gray_scale_material
