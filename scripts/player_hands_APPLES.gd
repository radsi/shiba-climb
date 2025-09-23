extends Node

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
var last_attached_left : Sprite2D = null
var last_attached_right : Sprite2D = null

var max_durability = 30.0
var durability_left = max_durability
var durability_right = max_durability
var drain_rate = 10.0
var slow_factor = 0.1
var grab_margin = 20.0

func _ready() -> void:
	hand_left.modulate = Color(1,1,1)
	hand_right.modulate = Color(1,1,1)
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position
	hand_left.texture = openhand_texture
	hand_right.texture = openhand_texture

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null:
			if event.pressed and not dragging_right:
				dragging_left = true
				last_pos_left = hand_left.global_position
				attached_left = get_apple_under_hand(hand_left)
				if attached_left != null:
					last_attached_left = attached_left
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
				if attached_right != null:
					last_attached_right = attached_right
				hand_right.texture = closehand_texture
			elif not event.pressed:
				dragging_right = false
				if attached_right == null:
					hand_right.texture = openhand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_half = get_viewport().size.x / 2
	var viewport_height = get_viewport().size.y
	process_hand_left(delta, mouse_pos, screen_half, viewport_height)
	process_hand_right(delta, mouse_pos, screen_half, viewport_height)

func process_hand_left(delta, mouse_pos, screen_half, viewport_height):
	if hand_left == null: return
	var factor = 0.5 if mouse_pos.x <= screen_half else slow_factor

	if dragging_left:
		hand_left.global_position = hand_left.global_position.lerp(mouse_pos, factor)

	if attached_left != null and attached_left.is_inside_tree():
		attached_left.global_position = hand_left.global_position
		hand_left.texture = closehand_texture
	elif attached_left != null:
		attached_left = null
		if not dragging_left:
			hand_left.texture = openhand_texture
	elif not dragging_left:
		hand_left.texture = openhand_texture

	if dragging_left or attached_left != null:
		durability_left -= drain_rate * delta
	else:
		durability_left += drain_rate/4 * delta

	durability_left = clamp(durability_left, 0, max_durability)
	hand_left.modulate = Color(1, durability_left/max_durability, durability_left/max_durability)

	if hand_left.global_position.y > viewport_height or durability_left <= 0:
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()
		hand_left.queue_free()
		hand_left = null
		attached_left = null
		last_attached_left = null
		dragging_left = false

func process_hand_right(delta, mouse_pos, screen_half, viewport_height):
	if hand_right == null: return
	var factor = 0.5 if mouse_pos.x >= screen_half else slow_factor

	if dragging_right:
		hand_right.global_position = hand_right.global_position.lerp(mouse_pos, factor)

	if attached_right != null and attached_right.is_inside_tree():
		attached_right.global_position = hand_right.global_position
		hand_right.texture = closehand_texture
	elif attached_right != null:
		attached_right = null
		if not dragging_right:
			hand_right.texture = openhand_texture
	elif not dragging_right:
		hand_right.texture = openhand_texture

	if dragging_right or attached_right != null:
		durability_right -= drain_rate * delta
	else:
		durability_right += drain_rate/4 * delta

	durability_right = clamp(durability_right, 0, max_durability)
	hand_right.modulate = Color(1, durability_right/max_durability, durability_right/max_durability)

	if hand_right.global_position.y > viewport_height or durability_right <= 0:
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()
		hand_right.queue_free()
		hand_right = null
		attached_right = null
		last_attached_right = null
		dragging_right = false

func get_apple_under_hand(hand: Node2D) -> Sprite2D:
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
