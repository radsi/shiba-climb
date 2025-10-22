extends HANDS

@onready var boss_manager = $".."
@onready var boss_hit = $"../hitboss"
@onready var valve_object = $"../Valve/Valve"
@onready var valve_sfx = $"../Valve/valve"
@onready var knock_sfx = $"../knock"
@onready var break_sfx = $"../break"
@onready var wall = $"../Wall"
@onready var keypad = $"../Vendor/Keypad"
@onready var beep = $"../beep"

var wall_hitted := false
var shaking := false
var top_limit := -220
var bottom_limit := 315
var left_limit := -500
var right_limit := 500

var old_mouse_pos := Vector2.ZERO
var original_hand_pos := []
var was_dragging_left := false
var was_dragging_right := false
var was_fingerhand_left := false
var was_fingerhand_right := false

func _ready():
	super._ready()
	original_hand_pos = [hand_left.global_position, hand_right.global_position]

func _process(delta):
	super._process(delta)
	was_dragging_left = dragging_left
	was_dragging_right = dragging_right
	was_fingerhand_left = hand_left.texture == globals.fingerhand_texture
	was_fingerhand_right = hand_right.texture == globals.fingerhand_texture

	var current_mouse_pos = get_local_mouse_position()

	if boss_manager.wall_hp > 0:
		_clamp_hands()

	if wall_hitted and (dragging_left or dragging_right):
		_shake_jail(Vector2.UP)
		_check_wall_distance()

	_handle_valve(current_mouse_pos)
	_handle_keypad_finger()

	if valve_object.rotation_degrees >= 2000:
		boss_manager.disable_valve()

	old_mouse_pos = current_mouse_pos

func _input(event):
	super._input(event)
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_keypad_press(hand_left)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_keypad_press(hand_right)

	if event is InputEventJoypadButton and globals.using_gamepad and not event.pressed:
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			_handle_keypad_press(hand_left)
		elif event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			_handle_keypad_press(hand_right)

func _handle_keypad_finger():
	if dragging_left and is_mouse_over_item(keypad, hand_left.global_position) and hand_left.visible == true:
		hand_left.texture = globals.fingerhand_texture
	if dragging_right and is_mouse_over_item(keypad, hand_right.global_position) and hand_right.visible == true:
		hand_right.texture = globals.fingerhand_texture

func _handle_valve(current_mouse_pos: Vector2):
	if not boss_manager.valve.visible:
		return
	if ((is_mouse_over_item(valve_object, hand_right.global_position) and dragging_right and hand_right.visible == true) or (is_mouse_over_item(valve_object, hand_left.global_position) and dragging_left and hand_left.visible == true)): 
		if ((hand_right.global_position.x != last_pos_right.x and globals.using_gamepad) or ((hand_left.global_position.x != last_pos_left.x and globals.using_gamepad))) or (current_mouse_pos.x != old_mouse_pos.x and not globals.using_gamepad): 
			valve_object.rotate(0.1) 
			if valve_sfx.is_playing() == false: 
				valve_sfx.play()

func _handle_keypad_press(hand: Node2D):
	var finger = hand.get_child(1)
	if not is_mouse_over_item(keypad, finger.global_position):
		return
	var nearest = _get_closest_keypad_child(finger)
	if nearest:
		boss_manager.hand_input += str(nearest.name)
		beep.play()

func _check_wall_distance():
	var dist_left = hand_left.global_position.distance_to(wall.global_position)
	var dist_right = hand_right.global_position.distance_to(wall.global_position)
	if dist_left > 10 and dist_right > 10:
		wall_hitted = false

func _clamp_hands():
	for hand in [hand_left, hand_right]:
		hand.position.y = clamp(hand.position.y, top_limit, bottom_limit)
		hand.position.x = clamp(hand.position.x, left_limit, right_limit)

func _shake_jail(direction: Vector2):
	if shaking:
		return
	shaking = true
	var base_pos = wall.position
	var offset = direction.normalized() * 8.0
	var tween = get_tree().create_tween()
	tween.tween_property(wall, "position", base_pos + offset, 0.05)
	tween.tween_property(wall, "position", base_pos, 0.10)
	await get_tree().create_timer(0.16).timeout
	shaking = false

func _get_closest_keypad_child(finger_tip: Node2D) -> Node2D:
	if not keypad or not finger_tip:
		return null
	var closest = null
	var min_dist := INF
	for child in keypad.get_children():
		if child is Node2D:
			var d = finger_tip.global_position.distance_to(child.global_position)
			if d < min_dist:
				min_dist = d
				closest = child
	return closest

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if not item:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	return Rect2(-size * 0.5, size).has_point(local_pos)

func hit_wall(body: Node2D):
	if not boss_manager.can_hit_wall or wall_hitted or shaking:
		return
	wall_hitted = true
	knock_sfx.play()
	boss_manager.wall_hp -= 1
	if boss_manager.wall_hp <= 0:
		body.get_parent().hide()
		break_sfx.play()
		top_limit = 0

func hit_boss(body: Node2D):
	if wall.visible or boss_manager.boss_hp <= 0:
		return
	boss_manager.eyes[0].texture = boss_manager.eye2_sprite
	boss_manager.eyes[1].texture = boss_manager.eye2_sprite
	boss_manager.boss_hp -= 1
	if boss_manager.boss_hp <= 0:
		boss_manager._kill_boss()
	else:
		boss_hit.play()
	body.get_parent().modulate = Color.RED
	var tween = get_tree().create_tween()
	tween.tween_property(body.get_parent(), "modulate", Color(1, 1, 1, 1), 1)
	block_left_hand_movement = true
	block_right_hand_movement = true
	var tween2 = get_tree().create_tween()
	tween2.tween_property(hand_left, "global_position", original_hand_pos[0], 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var tween3 = get_tree().create_tween()
	tween3.tween_property(hand_right, "global_position", original_hand_pos[1], 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween3.tween_callback(Callable(self, "_on_hands_moved"))
	for i in 30:
		await get_tree().create_timer(0.05).timeout
		_apply_random_transform(body.get_parent())
	body.get_parent().global_position = boss_manager.original_positions[0]

func _apply_random_transform(element):
	element.global_position = boss_manager.original_positions[0] + Vector2(randf_range(-4, 4), randf_range(-4, 4))

func _on_hands_moved():
	block_left_hand_movement = false
	block_right_hand_movement = false
	if boss_manager.boss_hp > 0:
		wall.show()
		boss_manager.wall_hp = 10
		top_limit = -220

func _on_areahand_body_shape_entered(body_rid, body: Node2D, body_shape_index, local_shape_index):
	if not body.get_parent().visible or (not dragging_left and not dragging_right):
		return
	match body.get_parent().name:
		"Wall":
			hit_wall(body)
		"Gas":
			hit_boss(body)
