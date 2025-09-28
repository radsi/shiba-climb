extends Node

@onready var rope = $Rope
@onready var girl_hand = $Rope/GirlHand

func _process(delta: float) -> void:
	if girl_hand.global_position.y >= 180: return
	rope.global_position.y -= globals.game_speed / 100
