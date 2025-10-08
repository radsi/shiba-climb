extends HANDS

@onready var coin: Sprite2D = $"../Coin"
@onready var keypad = $"../Keypad"
@onready var beep = $"../beep"
@onready var manager = $".."
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

var was_dragging_left := false
var was_dragging_right := false
var was_fingerhand_left := false
var was_fingerhand_right := false

func _ready():
	super._ready()
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _process(delta):
	was_dragging_left = dragging_left
	was_dragging_right = dragging_right
	was_fingerhand_left = hand_left.texture == globals.fingerhand_texture
	was_fingerhand_right = hand_right.texture == globals.fingerhand_texture

	super._process(delta)

	if is_mouse_over_item(keypad, hand_left.global_position):
		if dragging_left:
			hand_left.texture = globals.fingerhand_texture

	if is_mouse_over_item(keypad, hand_right.global_position):
		if dragging_right:
			hand_right.texture = globals.fingerhand_texture

	if coin == null:
		return

	update_attached_hand(attached_left, hand_left, true)
	update_attached_hand(attached_right, hand_right, false)

func update_attached_hand(attached, hand: Node2D, is_left: bool) -> void:
	if hand == null or not hand.is_inside_tree():
		return

	if is_left and dragging_left and attached_left == null:
		attach_hand_to_coin(hand, true)
	elif not is_left and dragging_right and attached_right == null:
		attach_hand_to_coin(hand, false)

	var dragging = dragging_left if is_left else dragging_right
	if not dragging and ((is_left and attached_left != null) or (not is_left and attached_right != null)):
		detach_hand(hand, is_left)

	if attached != null and attached.is_inside_tree():
		attached.global_position = Vector2(hand.global_position.x - [30, -30][int(is_left)], hand.global_position.y - 30)

func attach_hand_to_coin(hand: Node2D, is_left: bool) -> void:
	var local_pos = coin.to_local(hand.global_position)
	var size = coin.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		if is_left:
			attached_left = coin
		else:
			attached_right = coin
		hand.texture = globals.closehand_texture

func detach_hand(hand: Node2D, is_left: bool) -> void:
	if is_left:
		attached_left = null
	else:
		attached_right = null
	if hand != null and hand.is_inside_tree():
		hand.texture = globals.openhand_texture

func _get_finger_tip(hand: Node2D) -> Node2D:
	if hand.get_child_count() > 0:
		return hand.get_child(0)
	return null

func _get_closest_keypad_child(finger_tip: Node2D) -> Node2D:
	if keypad == null or finger_tip == null:
		return null

	var closest_child = null
	var min_dist := INF

	for child in keypad.get_children():
		if child is Node2D:
			var dist = finger_tip.global_position.distance_to(child.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_child = child

	return closest_child

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	return rect.has_point(local_pos)

func _input(event):
	super._input(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if was_dragging_left and was_fingerhand_left:
				var tip = _get_finger_tip(hand_left)
				var nearest = _get_closest_keypad_child(tip)
				if nearest:
					manager.hand_input += str(nearest.name)
					beep.play()

		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			if was_dragging_right and was_fingerhand_right:
				var tip = _get_finger_tip(hand_right)
				var nearest = _get_closest_keypad_child(tip)
				if nearest:
					manager.hand_input += str(nearest.name)
					beep.play()

	if event is InputEventJoypadButton and globals.using_gamepad:
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER and not event.pressed:
			if was_dragging_left and was_fingerhand_left:
				var tip = _get_finger_tip(hand_left)
				var nearest = _get_closest_keypad_child(tip)
				if nearest:
					manager.hand_input += str(nearest.name)
					beep.play()

		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER and not event.pressed:
			if was_dragging_right and was_fingerhand_right:
				var tip = _get_finger_tip(hand_right)
				var nearest = _get_closest_keypad_child(tip)
				if nearest:
					manager.hand_input += str(nearest.name)
					beep.play()
