extends CanvasLayer

@onready var label: Label = $Label


func _physics_process(delta: float) -> void:
	label.text = ""
	label.text += str("PPS:",int(1/Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)))
	label.text += str("\n","FPS:",Performance.get_monitor(Performance.TIME_FPS))
	label.text += str("\n","Nodes:",Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	label.text += str("\n","Memory:",int(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024),"MB")

func print_current_time() ->void:
	print(Time.get_unix_time_from_system())
