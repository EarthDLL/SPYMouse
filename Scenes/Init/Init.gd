extends Control

@export_enum("video","texture") var type :int = 1
@export var next_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == 1:
		var texture: Control = $Texture
		texture.modulate = Color8(255,255,255,0)
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(texture,"modulate",Color8(255,255,255,255),0.8)
		tween.tween_interval(1.5)
		tween.tween_property(texture,"modulate",Color8(255,255,255,0),0.8)
		await tween.finished
		_jump()
	if type == 0:
		$Video.finished.connect(_jump)
	
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			_jump()
	
func _jump() -> void:
	if next_scene != null:
		get_tree().change_scene_to_packed(next_scene)
