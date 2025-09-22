extends Node

@onready var head = $"../../RigidBody2D_Head"
@onready var hand_left = $"Hand1"
@onready var hand_right = $"Hand2"
@onready var grabables = $"../Grabables"

var openhand_texture = preload("res://open hand.png")
var closehand_texture = preload("res://fist hand.png")

var dragging_left = false
var dragging_right = false
var returning_left = false
var returning_right = false
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
var return_time = 0.3
var grab_margin = 20.0

func _ready() -> void:
	hand_left.texture = closehand_texture
	hand_right.texture = closehand_texture
	hand_left.modulate = Color(1,1,1)
	hand_right.modulate = Color(1,1,1)
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

	attached_left = $"../Grabables/StarterBrick"
	last_attached_left = attached_left
	attached_right = $"../Grabables/StarterBrick"
	last_attached_right = attached_right

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null and not returning_left:
			if event.pressed and not dragging_right:
				dragging_left = true
				last_pos_left = hand_left.global_position
				attached_left = null
				hand_left.texture = openhand_texture
			else:
				dragging_left = false
				var grabbed = get_grabable_under_hand(hand_left)
				if grabbed != null:
					attached_left = grabbed
					last_attached_left = grabbed
					last_pos_left = Vector2(hand_left.global_position.x, attached_left.global_position.y)
					hand_left.global_position.y = attached_left.global_position.y
				else:
					return_hand_left()
				hand_left.texture = closehand_texture

		if event.button_index == MOUSE_BUTTON_RIGHT and hand_right != null and not returning_right:
			if event.pressed and not dragging_left:
				dragging_right = true
				last_pos_right = hand_right.global_position
				attached_right = null
				hand_right.texture = openhand_texture
			else:
				dragging_right = false
				var grabbed_r = get_grabable_under_hand(hand_right)
				if grabbed_r != null:
					attached_right = grabbed_r
					last_attached_right = grabbed_r
					last_pos_right = Vector2(hand_right.global_position.x, attached_right.global_position.y)
					hand_right.global_position.y = attached_right.global_position.y
				else:
					return_hand_right()
				hand_right.texture = closehand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_half = get_viewport().size.x / 2
	var viewport_height = get_viewport().size.y

	process_hand_left(delta, mouse_pos, screen_half, viewport_height)
	process_hand_right(delta, mouse_pos, screen_half, viewport_height)

func process_hand_left(delta, mouse_pos, screen_half, viewport_height):
	if hand_left == null:
		return

	var factor = slow_factor
	if mouse_pos.x <= screen_half:
		factor = 0.5
	else:
		factor = 0.1

	if dragging_left:
		var target_pos = hand_left.global_position.lerp(mouse_pos, factor)
		hand_left.global_position = target_pos
		attached_left = null
	else:
		if attached_left != null:
			if not attached_left.is_inside_tree():
				attached_left = null
			else:
				hand_left.global_position.y = attached_left.global_position.y
				last_pos_left = Vector2(hand_left.global_position.x, attached_left.global_position.y)

	if dragging_left:
		durability_left -= drain_rate * delta
	else:
		durability_left += drain_rate/4 * delta

	durability_left = clamp(durability_left, 0, max_durability)
	hand_left.modulate = Color(1, durability_left/max_durability, durability_left/max_durability)

	if hand_left.global_position.y > viewport_height or durability_left <= 0:
		hand_left.queue_free()
		hand_left = null
		attached_left = null
		last_attached_left = null
		dragging_left = false
		returning_left = false

func process_hand_right(delta, mouse_pos, screen_half, viewport_height):
	if hand_right == null:
		return

	var factor = slow_factor
	if mouse_pos.x >= screen_half:
		factor = 0.5
	else:
		factor = 0.1

	if dragging_right:
		var target_pos = hand_right.global_position.lerp(mouse_pos, factor)
		hand_right.global_position = target_pos
		attached_right = null
	else:
		if attached_right != null:
			if not attached_right.is_inside_tree():
				attached_right = null
			else:
				hand_right.global_position.y = attached_right.global_position.y
				last_pos_right = Vector2(hand_right.global_position.x, attached_right.global_position.y)

	if dragging_right:
		durability_right -= drain_rate * delta
	else:
		durability_right += drain_rate/4 * delta

	durability_right = clamp(durability_right, 0, max_durability)
	hand_right.modulate = Color(1, durability_right/max_durability, durability_right/max_durability)

	if hand_right.global_position.y > viewport_height or durability_right <= 0:
		hand_right.queue_free()
		hand_right = null
		attached_right = null
		last_attached_right = null
		dragging_right = false
		returning_right = false

func return_hand_left():
	if hand_left == null:
		return
	var target_y = last_pos_left.y
	if last_attached_left != null and last_attached_left.is_inside_tree():
		target_y = last_attached_left.global_position.y - 5
	var target = Vector2(last_pos_left.x, target_y)
	returning_left = true

	var tween = create_tween()
	tween.tween_property(hand_left, "global_position", target, return_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_return_left_done)

func return_hand_right():
	if hand_right == null:
		return
	var target_y = last_pos_right.y
	if last_attached_right != null and last_attached_right.is_inside_tree():
		target_y = last_attached_right.global_position.y - 5
	var target = Vector2(last_pos_right.x, target_y)
	returning_right = true

	var tween = create_tween()
	tween.tween_property(hand_right, "global_position", target, return_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_return_right_done)

func _on_return_left_done():
	returning_left = false
	if last_attached_left != null and last_attached_left.is_inside_tree():
		attached_left = last_attached_left
	if hand_left != null:
		hand_left.texture = closehand_texture

func _on_return_right_done():
	returning_right = false
	if last_attached_right != null and last_attached_right.is_inside_tree():
		attached_right = last_attached_right
	if hand_right != null:
		hand_right.texture = closehand_texture

func get_grabable_under_hand(hand: Node2D) -> Sprite2D:
	for g in grabables.get_children():
		if g is Sprite2D and g.texture != null:
			var size = g.texture.get_size() * g.scale
			var rect = Rect2(g.global_position - size * 0.5, size)
			if rect.has_point(hand.global_position):
				return g
			var max_half = max(size.x, size.y) * 0.5
			if hand.global_position.distance_to(g.global_position) <= max_half + grab_margin:
				return g
	return null
