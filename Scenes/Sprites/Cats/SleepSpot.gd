extends Area2D
class_name SleepSpot


@export var sleep_time := 5.0

func found_target(body : Node2D) -> void:
	if body is Cat && body.is_sleepable:
		if body.state == Cat.STATE.WALK:
			body.sleep(self)
