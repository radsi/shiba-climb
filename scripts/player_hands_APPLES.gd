extends Node2D

@onready var hand_left = $"Hand1"
@onready var hand_right = $"Hand2"
@onready var apples = $"../Apples"

var openhand_texture = preload("res://open hand.png")
var closehand_texture = preload("res://fist hand.png")

var dragging_left = false
var dragging_right = false
var last_pos_left = Vector2.ZERO
var last_pos_right = Vector2.ZERO
var attached_left : Sprite2D = null
var attached_right : Sprite2D = null

var max_durability = 30.0
var durability_left = max_durability
var durability_right = max_durability
var drain_rate = 10.0
var slow_factor = 0.1
var grab_margin = 20.0

func _ready():
	hand_left.texture = openhand_texture
	hand_right.texture = openhand_texture
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null:
			if event.pressed and not dragging_right:
				dragging_left = true
				last_pos_left = hand_left.global_position
				attached_left = get_apple_under_hand(hand_left)
				hand_left.texture = closehand_texture
			elif not event.pressed:
				dragging_left = false
				if attached_left == null:
					hand_left.texture = openhand_texture

		if event.button_index == MOUSE_BUTTON_RIGHT and hand_right != null:
			if event.pressed and not dragging_left:
				dragging_right = true
				last_pos_right = hand_right.global_position
				attached_right = get_apple_under_hand(hand_right)
				hand_right.texture = closehand_texture
			elif not event.pressed:
				dragging_right = false
				if attached_right == null:
					hand_right.texture = openhand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_half = get_viewport().get_visible_rect().size.x / 2

	var viewport_height = get_viewport().size.y

	process_hand(hand_left, dragging_left, true, delta, mouse_pos, screen_half, viewport_height)
	process_hand(hand_right, dragging_right, false, delta, mouse_pos, screen_half, viewport_height)

	last_pos_left = hand_left.global_position if hand_left != null else last_pos_left
	last_pos_right = hand_right.global_position if hand_right != null else last_pos_right

func process_hand(hand: Sprite2D, dragging: bool, is_left: bool, delta: float, mouse_pos: Vector2, screen_half: float, viewport_height: float) -> void:
	if hand == null:
		return

	var factor = 0.5
	if is_left and hand.global_position.x > screen_half:
		factor = slow_factor
	elif not is_left and hand.global_position.x < screen_half:
		factor = slow_factor

	if dragging:
		hand.global_position = hand.global_position.lerp(mouse_pos, factor)

	var attached = attached_left if is_left else attached_right
	if attached != null and attached.is_inside_tree():
		attached.global_position = hand.global_position
	elif attached != null:
		if is_left:
			attached_left = null
		else:
			attached_right = null
		if not dragging:
			hand.texture = openhand_texture
	elif not dragging:
		hand.texture = openhand_texture

	if dragging or attached != null:
		if is_left:
			durability_left -= drain_rate * delta
		else:
			durability_right -= drain_rate * delta
	else:
		if is_left:
			durability_left += drain_rate/4 * delta
		else:
			durability_right += drain_rate/4 * delta

	if is_left:
		durability_left = clamp(durability_left, 0, max_durability)
		hand.modulate = Color(1, durability_left/max_durability, durability_left/max_durability)
	else:
		durability_right = clamp(durability_right, 0, max_durability)
		hand.modulate = Color(1, durability_right/max_durability, durability_right/max_durability)

	if hand.global_position.y > viewport_height or (is_left and durability_left <= 0) or (not is_left and durability_right <= 0):
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()
		hand.queue_free()
		if is_left:
			hand_left = null
			attached_left = null
		else:
			hand_right = null
			attached_right = null

func get_apple_under_hand(hand: Sprite2D) -> Sprite2D:
	for apple in apples.get_children():
		if apple is Sprite2D and apple.texture != null:
			var size = apple.texture.get_size() * apple.scale
			var rect = Rect2(apple.global_position - size*0.5, size)
			if rect.has_point(hand.global_position):
				return apple
			var max_half = max(size.x, size.y) * 0.5
			if hand.global_position.distance_to(apple.global_position) <= max_half + grab_margin:
				return apple
	return null
