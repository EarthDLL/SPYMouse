@tool
extends Area2D

@export var type := 0:
	set(value):
		if clampi(value,0,3) == value:
			type = value
			$Sprite.frame = type
@export var note_index := 1:
	set(value):
		if clampi(value,1,13) == value:
			note_index = value
@onready var sound: AudioStreamPlayer = $Sound
@onready var common_sound: AudioStreamPlayer = $CommonSound

func _ready() -> void:
	if !Engine.is_editor_hint():
		Game.current_level.little_cheese_count += 1

func collect() -> void:
	$Sprite.hide()
	set_deferred("monitorable",false)
	var score := 1
	match type:
		0:
			Game.current_player.update_little_cheese_score()
			score = Game.current_player.last_little_cheese_score
		1:
			score = 10
		2:
			score = 15
		3:
			score = 25
	Game.current_level.add_score(score)
	Game.current_level.collected_little_cheese += 1
	Animations.little_cheese_ainma(global_position,score)
	sound.stream = load("res://Resource/sound/ui/score_note"+str(note_index)+".wav")
	sound.play()
	common_sound.play()
	sound.finished.connect(queue_free)
	
