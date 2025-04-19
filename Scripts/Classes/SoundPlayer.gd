extends AudioStreamPlayer
class_name SoundPlayer

@export var sounds := {}

func play_sound(id : String) -> void:
	if sounds.has(id):
		var sound = sounds.get(id)
		if sound is AudioStream:
			set_stream(sound)
			play()

func play_global_sound(id : String) -> void:
	if Game.global_sounds.has(id):
		var sound = Game.global_sounds.get(id)
		if sound is AudioStream:
			set_stream(sound)
			play()
