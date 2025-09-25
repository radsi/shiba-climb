extends Node

var timer_colors = ["#ABCDCB", "#EBE59B", "#E78775", "#C84361"]
@onready var timer = $TimerColor
var initial_scale := Vector2.ONE

func _ready() -> void:
	initial_scale = timer.scale

func _process(delta: float) -> void:
	$".".get_child(2).text = str(globals.life)

	var max_time
	if globals.is_long:
		max_time = globals.game_time_long
	else:
		max_time = globals.game_time
	var t = clamp(globals.time_left / max_time, 0.0, 1.0)

	var idx = int(floor((1.0 - t) * (timer_colors.size() - 1)))
	if globals.is_long:
		idx = timer_colors.size() - 1 - idx
	timer.color = Color(timer_colors[idx])

	if not globals.is_long:
		timer.scale.x = initial_scale.x * t
	else:
		timer.scale.x = initial_scale.x * (1.0 - t)
