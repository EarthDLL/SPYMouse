extends Node
class_name Data

@onready var timer: Timer = $Timer
var total_paths := 0
var score := 0
var found_time := 0
var stupid_cat_crash_count := 0

func start() -> void:
	timer.start()
	
func get_used_time() -> float:
	if timer.is_stopped():
		return 10000.0
	return 10000 - timer.time_left

func finish() -> void:
	timer.paused = true

func set_score(s : int) -> void:
	score = s
	
func update_timer(state : bool) -> void:
	if state && timer.paused:
		timer.set_paused(false)
	if !state && !timer.is_stopped():
		timer.set_paused(true)
