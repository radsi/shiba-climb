extends HANDS

@onready var rope: Node2D = $"../Rope"
@onready var girl_hand = $"../Rope/GirlHand"

var grab_margin: float = 20.0
var rope_move_factor: float = 0.3
var sound_played: bool = false

func _ready() -> void:
	super._ready()
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _process(delta: float) -> void:
	super._process(delta)
	
	if girl_hand.global_position.y >= 180:
		globals.minigame_completed = true
		return

	if dragging_left:
		_handle_hand_move_over_rope(hand_left, last_pos_left)
	elif dragging_right:
		_handle_hand_move_over_rope(hand_right, last_pos_right)
	else:
		sound_played = false

	if dragging_left:
		last_pos_left = hand_left.global_position
	if dragging_right:
		last_pos_right = hand_right.global_position

func _handle_hand_move_over_rope(hand: Node2D, prev_pos: Vector2) -> void:
	if rope == null:
		return

	var dy = hand.global_position.y - prev_pos.y
	if dy <= 0:
		return

	rope.global_position.y += dy * rope_move_factor

	if not sound_played:
		get_node("../rope" + str(randi() % 2 + 1)).play()
		sound_played = true
