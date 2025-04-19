extends Node2D

@onready var anima_point: Control = $Cheese/StartBtn/AnimaPoint


func _start_btn_pressed() -> void:	
	%StartBtn.disabled = true
	Game.button_sound()
	BgLayer.anima(MoveShape.anima.IN,"blue","hole",anima_point.global_position,true,true)
	BgLayer.show_loading_text()
	await BgLayer.anima_finsished
	get_tree().change_scene_to_file(Save.world_paths[1])

func _ready() -> void:
	if BgLayer.is_showing:
		BgLayer.try_anima(anima_point.global_position)
