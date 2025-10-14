extends Node

@onready var ball = $Ball

var timer = 0

func _ready() -> void:
	globals.hands_drain_rate /= 2

func _process(delta: float) -> void:
	
	timer += delta
	
	if ball.global_position.y >= 1000:
		if globals.is_single_minigame:
			globals._game_over()
		else:
			if globals.has_lost_life == false: globals.life -= 1
			globals.has_lost_life = true
			globals._start_roll()

	if timer >= 30:
		globals._unlock_minigame("Vendor")
		globals._unlock_hands("real")
