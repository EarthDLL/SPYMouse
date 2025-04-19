extends Level
class_name BossLevel

@export var signaler : VisibleOnScreenNotifier2D = null
@export var camera : Camera2D = null


func _ready() -> void:
	camera.reset_smoothing()
	camera.force_update_scroll()
	player.path = player_path
	if is_instance_valid(signaler):
		signaler.screen_exited.connect(Callable(self,"fail").bind(0.1,player.global_position))
	for cat : Cat in get_tree().get_nodes_in_group("Cat"):
		if is_instance_valid(cat) && cat is BossCat:
			cat.fail.connect(fail_by_checked)
	
func fail_by_checked() -> void:
	fail(3.0,player.global_position)
