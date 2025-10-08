extends Node

@onready var ball = $Ball

func _ready() -> void:
	globals.hands_drain_rate /= 2

func _process(delta: float) -> void:
	if ball.global_position.y >= 1000:
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()

	if delta >= 15:
		globals._unlock_minigame("Vendor")
		globals._unlock_hands("real")
