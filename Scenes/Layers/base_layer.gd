extends CanvasLayer


func _on_update_btn_pressed() -> void:
	var node := load("res://Scenes/UI/TextBar.tscn").instantiate() as TextBar
	add_child(node)
	node.set_title("更新日志")
	var file := FileAccess.open("res://Update.txt",FileAccess.READ)
	if is_instance_valid(file):
		node.set_text(file.get_as_text())
	file.close()
	node.popup()

func _on_setting_btn_pressed() -> void:
	var node := load("res://Scenes/UI/SettingBar.tscn").instantiate() as TextBar
	add_child(node)
	node.popup()
