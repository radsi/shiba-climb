extends Node

@onready var ball = $Ball

func _ready() -> void:
	if not globals.is_single_minigame:
		globals.hands_drain_rate /= 2

func _process(delta: float) -> void:
	if ball.global_position.y >= 1000:
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()
