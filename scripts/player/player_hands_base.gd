class_name HANDS
extends Node2D

@onready var hand_left = $"Hand1"
@onready var hand_right = $"Hand2"

var dragging_left = false
var dragging_right = false
var durability_left = globals.hands_max_durability
var durability_right = globals.hands_max_durability
var slow_factor = 0.1
var grappling = false

var last_pos_left = Vector2.ZERO
var last_pos_right = Vector2.ZERO

func _ready():
	hand_left.modulate = Color(1,1,1)
	hand_right.modulate = Color(1,1,1)

	if grappling:
		hand_left.texture = globals.closehand_texture
		hand_right.texture = globals.closehand_texture
	else:
		hand_left.texture = globals.openhand_texture
		hand_right.texture = globals.openhand_texture

	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null:
			if event.pressed and durability_left > 0:
				dragging_left = true
				if grappling:
					hand_left.texture = globals.openhand_texture
				else:
					hand_left.texture = globals.closehand_texture
			else:
				dragging_left = false
				if grappling:
					hand_left.texture = globals.closehand_texture
				else:
					hand_left.texture = globals.openhand_texture

		if event.button_index == MOUSE_BUTTON_RIGHT and hand_right != null:
			if event.pressed and durability_right > 0:
				dragging_right = true
				if grappling:
					hand_right.texture = globals.openhand_texture
				else:
					hand_right.texture = globals.closehand_texture
			else:
				dragging_right = false
				if grappling:
					hand_right.texture = globals.closehand_texture
				else:
					hand_right.texture = globals.openhand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_half = get_viewport().get_visible_rect().size.x / 2
	
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

	process_hand(hand_left, dragging_left, true, delta, mouse_pos, screen_half)
	process_hand(hand_right, dragging_right, false, delta, mouse_pos, screen_half)

func process_hand(hand: Node2D, dragging: bool, is_left: bool, delta: float, mouse_pos: Vector2, screen_half: float):
	if hand == null:
		return

	var durability = durability_left if is_left else durability_right
	var factor = slow_factor

	if is_left and mouse_pos.x <= screen_half:
		factor = 0.5
	elif not is_left and mouse_pos.x >= screen_half:
		factor = 0.5

	if dragging and durability > 0:
		var target_pos = mouse_pos
		hand.global_position = hand.global_position.lerp(target_pos, factor)
		durability -= globals.hands_drain_rate * delta
	else:
		durability += globals.hands_drain_rate / 4 * delta

	durability = clamp(durability, 0, globals.hands_max_durability)
	hand.modulate = Color(1, durability / globals.hands_max_durability, durability / globals.hands_max_durability)

	if is_left:
		durability_left = durability
		if durability_left <= 0:
			dragging_left = false
			hand.texture = globals.closehand_texture
			globals.life -= 1
			globals.has_lost_life = true
			globals._start_roll()
			hand.queue_free()
	else:
		durability_right = durability
		if durability_right <= 0:
			dragging_right = false
			hand.texture = globals.closehand_texture
			globals.life -= 1
			globals.has_lost_life = true
			globals._start_roll()
			hand.queue_free()
