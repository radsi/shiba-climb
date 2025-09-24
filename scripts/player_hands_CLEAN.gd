extends Node

@onready var hand_left = $"Hand1"
@onready var hand_right = $"Hand2"
@onready var dirty_objects = $"../Dirty"

var dragging_left = false
var dragging_right = false
var durability_left = 30.0
var durability_right = 30.0
var max_durability = 30.0
var drain_rate = 8.0
var slow_factor = 0.1
var transparency_step = 0.01

var last_pos_left = Vector2.ZERO
var last_pos_right = Vector2.ZERO

var openhand_texture = preload("res://open hand.png")
var closehand_texture = preload("res://fist hand.png")

func _ready():
	hand_left.modulate = Color(1,1,1)
	hand_right.modulate = Color(1,1,1)
	hand_left.texture = closehand_texture
	hand_right.texture = closehand_texture
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null:
			if event.pressed and durability_left > 0:
				dragging_left = true
				hand_left.texture = openhand_texture
			else:
				dragging_left = false
				hand_left.texture = closehand_texture
		if event.button_index == MOUSE_BUTTON_RIGHT and hand_right != null:
			if event.pressed and durability_right > 0:
				dragging_right = true
				hand_right.texture = openhand_texture
			else:
				dragging_right = false
				hand_right.texture = closehand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_half = get_viewport().get_visible_rect().size.x / 2

	process_hand(hand_left, dragging_left, true, delta, mouse_pos, screen_half)
	process_hand(hand_right, dragging_right, false, delta, mouse_pos, screen_half)

	increase_transparency_under_hand(hand_left, last_pos_left)
	increase_transparency_under_hand(hand_right, last_pos_right)

	last_pos_left = hand_left.global_position if hand_left != null else last_pos_left
	last_pos_right = hand_right.global_position if hand_right != null else last_pos_right

func process_hand(hand: Node2D, dragging: bool, is_left: bool, delta: float, mouse_pos: Vector2, screen_half: float):
	if hand == null:
		return

	var durability = durability_left if is_left else durability_right
	var factor = 0.5 if (is_left and mouse_pos.x <= screen_half) or (not is_left and mouse_pos.x >= screen_half) else slow_factor

	if dragging and durability > 0:
		var target_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
		hand.global_position = hand.global_position.lerp(target_pos, factor)
		durability -= drain_rate * delta
	else:
		durability += drain_rate / 4 * delta

	durability = clamp(durability, 0, max_durability)
	hand.modulate = Color(1, durability / max_durability, durability / max_durability)

	if is_left:
		durability_left = durability
		if durability_left <= 0:
			dragging_left = false
			hand.texture = closehand_texture
			globals.life -= 1
			globals.has_lost_life = true
			globals._start_roll()
			hand.queue_free()
	else:
		durability_right = durability
		if durability_right <= 0:
			dragging_right = false
			hand.texture = closehand_texture
			globals.life -= 1
			globals.has_lost_life = true
			globals._start_roll()
			hand.queue_free()

func increase_transparency_under_hand(hand: Node2D, last_pos: Vector2):
	if hand == null:
		return

	if hand.global_position.distance_to(last_pos) < 1:
		return

	for obj in dirty_objects.get_children():
		if obj is Sprite2D and obj.texture != null:
			var size = obj.texture.get_size() * obj.scale
			var rect = Rect2(obj.global_position - size * 0.5, size)
			if rect.has_point(hand.global_position):
				var c = obj.modulate
				c.a = clamp(c.a - transparency_step, 0, 1)
				obj.modulate = c
