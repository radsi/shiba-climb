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

var wall_hitted = false
var shaking := false
var top_limit = -220
var bottom_limit = 315
var left_limit = -500
var right_limit = 500

var old_mouse_pos := Vector2.ZERO
var original_hand_pos = []

var was_dragging_left := false
var was_dragging_right := false
var was_fingerhand_left := false
var was_fingerhand_right := false

func _ready():
	super._ready()
	original_hand_pos.append(hand_left.global_position)
	original_hand_pos.append(hand_right.global_position)

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
	
	if valve_object.rotation_degrees >= 2000:
		boss_manager.disable_valve()
	
	var current_mouse_pos = get_local_mouse_position()

	if wall_hitted and (dragging_left or dragging_right):
		_shake_jail(Vector2.UP)
	
	if is_mouse_over_item(valve_object, hand_left.global_position) and dragging_left and boss_manager.valve.visible:
		if (hand_left.global_position.x != last_pos_left.x and globals.using_gamepad) or (current_mouse_pos.x != old_mouse_pos.x and not globals.using_gamepad):
			valve_object.rotate(0.1)
			if valve_sfx.is_playing() == false: valve_sfx.play()

	if is_mouse_over_item(valve_object, hand_right.global_position) and dragging_right and boss_manager.valve.visible:
		if (hand_right.global_position.x != last_pos_right.x and globals.using_gamepad) or (current_mouse_pos.x != old_mouse_pos.x and not globals.using_gamepad):
			valve_object.rotate(0.1)
			if valve_sfx.is_playing() == false: valve_sfx.play()
	
	if boss_manager.wall_hp > 0:
		hand_left.position.y = clamp(hand_left.position.y, top_limit, bottom_limit)
		hand_right.position.y = clamp(hand_right.position.y, top_limit, bottom_limit)
		hand_left.position.x = clamp(hand_left.position.x, left_limit, right_limit)
		hand_right.position.x = clamp(hand_right.position.x, left_limit, right_limit)
	
	old_mouse_pos = current_mouse_pos

func _input(event):
	super._input(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if was_dragging_left and was_fingerhand_left and is_mouse_over_item(keypad, hand_right.get_child(1).global_position):
				var nearest = _get_closest_keypad_child(hand_left.get_child(1))
				if nearest:
					print(nearest.name)
					boss_manager.hand_input += str(nearest.name)
					beep.play()

		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			if was_dragging_right and was_fingerhand_right and is_mouse_over_item(keypad, hand_right.get_child(1).global_position):
				var nearest = _get_closest_keypad_child(hand_right.get_child(1))
				if nearest:
					print(nearest.name)
					boss_manager.hand_input += str(nearest.name)
					beep.play()

	if event is InputEventJoypadButton and globals.using_gamepad:
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER and not event.pressed:
			if was_dragging_left and was_fingerhand_left and is_mouse_over_item(keypad, hand_right.get_child(1).global_position):
				var nearest = _get_closest_keypad_child(hand_left.get_child(1))
				if nearest:
					boss_manager.hand_input += str(nearest.name)
					beep.play()

		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER and not event.pressed:
			if was_dragging_right and was_fingerhand_right and is_mouse_over_item(keypad, hand_right.get_child(1).global_position):
				var nearest = _get_closest_keypad_child(hand_right.get_child(1))
				if nearest:
					boss_manager.hand_input += str(nearest.name)
					beep.play()

func _shake_jail(direction: Vector2) -> void:
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

func hit_wall(body: Node2D):
	if not boss_manager.can_hit_wall: return
	knock_sfx.play()
	boss_manager.wall_hp -= 1
	if boss_manager.wall_hp <= 0:
		body.get_parent().hide()
		break_sfx.play()
		top_limit = 0
	wall_hitted = true

func hit_boss(body: Node2D):
	if wall.visible == true or boss_manager.boss_hp <= 0: return
	boss_manager.eyes[0].texture = boss_manager.eye2_sprite
	boss_manager.eyes[1	].texture = boss_manager.eye2_sprite
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
	for i in range(30):
		await get_tree().create_timer(0.05).timeout
		_apply_random_transform(body.get_parent())
	body.get_parent().global_position = boss_manager.original_positions[0]
	
	
func _apply_random_transform(element) -> void:
	element.global_position = boss_manager.original_positions[0] + Vector2(
		randf_range(-4, 4),
		randf_range(-4, 4)
	)

func _on_hands_moved():
	block_left_hand_movement = false
	block_right_hand_movement = false
	if boss_manager.boss_hp > 0: 
		wall.show()
		boss_manager.wall_hp = 10
		top_limit = -220

func _on_areahand_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.get_parent().visible == false or (not dragging_left and not dragging_right): return
	match(body.get_parent().name):
		"Wall":
			hit_wall(body)
		"Gas":
			hit_boss(body)
	
	
func _on_areahand_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.get_parent().visible == false: return
	wall_hitted = false
