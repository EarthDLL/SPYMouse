extends AccessNode
class_name Door



@onready var anima: AnimationPlayer = $Anima
@onready var level : Level = null
@onready var sound_player: SoundPlayer = $SoundPlayer
@export var is_hidden := false



func _ready() -> void:
	if is_hidden:
		access_open()

func access_open() -> void:
	is_opened = true
	var tween := create_tween()
	tween.tween_property($Door,"frame",3,0.4)
	$Arrow.show()
	anima.play("Move")
	sound_player.play_sound("Open")

func access_close() -> void:
	is_opened = false
	var tween := create_tween()
	tween.tween_property($Door,"frame",0,0.4)
	$Arrow.hide()
	anima.play("Idle")
	sound_player.play_sound("Close")

	
func get_point() -> Vector2:
	return $Point.global_position
func get_item_point() -> Vector2:
	return $ItemPoint.global_position
	
func player_in_door(wait_to_close : float) -> void:
	await get_tree().create_timer(wait_to_close).timeout
	access_close()
