extends TextBar

@onready var sound_slider: HSlider = $Container/Panel/Texts/Box/SoundSlider
@onready var music_slider: HSlider = $Container/Panel/Texts/Box/MusicSlider
@onready var special_mode_hide: CheckButton = $Container/Panel/Texts/Box/SpecialModeHide
@onready var special_mode_cheese: CheckButton = $Container/Panel/Texts/Box/SpecialModeCheese

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	special_mode_hide.set_pressed_no_signal(Save.get_setting("SpecialModeHiddenCat",1,false))
	special_mode_cheese.set_pressed_no_signal(Save.get_setting("SpecialModeCheeseTrap",1,false))
	

func _on_sound_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Sound"),
			linear_to_db(sound_slider.value))
		Save.set_setting("Sound",sound_slider.value)

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"),
			linear_to_db(music_slider.value))
		Save.set_setting("Music",music_slider.value)

func on_special_mode_hide(state : bool) -> void:
	Save.set_setting("SpecialModeHiddenCat",state)

func on_special_mode_cheese(state : bool) -> void:
	Save.set_setting("SpecialModeCheeseTrap",state)
