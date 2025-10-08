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

var block_left_hand_movement = false
var block_right_hand_movement = false

func _ready():
	hand_left.modulate = Color(1,1,1)
	hand_right.modulate = Color(1,1,1)

	modulate = globals.hands_color

	if grappling:
		hand_left.texture = globals.closehand_texture
		hand_right.texture = globals.closehand_texture
	else:
		hand_left.texture = globals.openhand_texture
		hand_right.texture = globals.openhand_texture

	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _input(event):
	if globals.using_gamepad:
		if event is InputEventJoypadButton:
			if hand_left != null and durability_left > 0:
				if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
					if event.pressed:
						dragging_left = true
						hand_left.texture = globals.closehand_texture if not grappling else globals.openhand_texture
					else:
						dragging_left = false
						hand_left.texture = globals.openhand_texture if not grappling else globals.closehand_texture

			if hand_right != null and durability_right > 0:
				if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
					if event.pressed:
						dragging_right = true
						hand_right.texture = globals.closehand_texture if not grappling else globals.openhand_texture
					else:
						dragging_right = false
						hand_right.texture = globals.openhand_texture if not grappling else globals.closehand_texture

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null:
			if event.pressed and durability_left > 0:
				dragging_left = true
				hand_left.texture = globals.closehand_texture if not grappling else globals.openhand_texture
			else:
				dragging_left = false
				hand_left.texture = globals.openhand_texture if not grappling else globals.closehand_texture

		if event.button_index == MOUSE_BUTTON_RIGHT and hand_right != null:
			if event.pressed and durability_right > 0:
				dragging_right = true
				hand_right.texture = globals.closehand_texture if not grappling else globals.openhand_texture
			else:
				dragging_right = false
				hand_right.texture = globals.openhand_texture if not grappling else globals.closehand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_half = get_viewport().get_visible_rect().size.x / 2

	var move_left = Vector2.ZERO
	var move_right = Vector2.ZERO

	if globals.using_gamepad:
		move_left = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		move_right = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))

	if hand_left != null and not block_left_hand_movement:
		if move_left.length() > 0.1:
			var factor = 1 if hand_left.global_position.x <= screen_half else 0.5
			var target_pos = hand_left.global_position + move_left * 700 * delta
			hand_left.global_position = hand_left.global_position.lerp(target_pos, factor)
		process_hand(hand_left, dragging_left, true, delta, mouse_pos, screen_half)

	if hand_right != null and not block_right_hand_movement:
		if move_right.length() > 0.1:
			var factor = 1 if hand_right.global_position.x >= screen_half else 0.5
			var target_pos = hand_right.global_position + move_right * 700 * delta
			hand_right.global_position = hand_right.global_position.lerp(target_pos, factor)
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
		if not globals.using_gamepad:
			var target_pos = mouse_pos
			hand.global_position = hand.global_position.lerp(target_pos, factor)
		durability -= globals.hands_drain_rate * delta
	else:
		durability += globals.hands_drain_rate / 3 * delta

	durability = clamp(durability, 0, globals.hands_max_durability)
	hand.modulate = Color(1, durability / globals.hands_max_durability, durability / globals.hands_max_durability)

	if durability_left <= 0 or durability_right <= 0:
		hand.texture = globals.closehand_texture
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()
		hand.queue_free()

	if is_left:
		durability_left = durability
		if durability_left <= 0:
			dragging_left = false
	else:
		durability_right = durability
		if durability_right <= 0:
			dragging_right = false
