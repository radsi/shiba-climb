extends Node

@onready var gallery_locked_sprite = preload("res://gallery item locked.png")
@onready var bg1 = $Bg
@onready var bg2 = $Bg2
@onready var button_back = $buttonback
@onready var button_left = $left
@onready var button_right = $right
@onready var buttons = []

var item_under_mouse: Sprite2D = null
var page = 1
var max_page = 1
var current_button = 1

var prev_dpad_left := false
var prev_dpad_right := false
var prev_dpad_up := false
var prev_dpad_down := false

var prev_axis_x := 0.0
var prev_axis_y := 0.0
var prev_button_a := false
var prev_button_b := false

func _ready():
	bg1.global_position.y = globals.current_menu_bg_pos[0]
	bg2.global_position.y = globals.current_menu_bg_pos[1]
	max_page = get_tree().get_nodes_in_group("pages").size()
	$AnimationPlayer.play("arrow_green")
	$AnimationPlayer2.play("arrow_back")
	_refresh_buttons()
	_refresh_gallery()

func _process(delta):
	_handle_dpad_input()
	_handle_joystick_input()
	_scroll_background()
	_highlight_items()

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_B:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		elif event.button_index == JOY_BUTTON_A:
			if current_button == 0:
				get_tree().change_scene_to_file("res://scenes/menu.tscn")
			elif current_button == 7:
				_on_left_pressed()
			elif current_button == 8:
				_on_right_pressed()
			elif item_under_mouse:
				var icon = item_under_mouse.get_child(0)
				if icon:
					if item_under_mouse.get_meta("unlocked"): globals.start_single_minigame(icon.name)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not globals.using_gamepad and item_under_mouse:
		var icon = item_under_mouse.get_child(0)
		if icon and item_under_mouse.get_meta("unlocked"):
			globals.start_single_minigame(icon.name)

func _handle_dpad_input():
	var dpad_left = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT)
	var dpad_right = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT)
	var dpad_up = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP)
	var dpad_down = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN)

	# Horizontal
	if dpad_left and not prev_dpad_left:
		current_button = clamp(current_button - 1, 0, buttons.size() - 1)
		_clamp_visible_button(-1)
	elif dpad_right and not prev_dpad_right:
		current_button = clamp(current_button + 1, 0, buttons.size() - 1)
		_clamp_visible_button(1)

	# Vertical
	elif dpad_up and not prev_dpad_up:
		current_button -= 3
		_clamp_visible_button(-3)
	elif dpad_down and not prev_dpad_down:
		current_button += 3
		_clamp_visible_button(3)

	current_button = clamp(current_button, 0, buttons.size() - 1)
	prev_dpad_left = dpad_left
	prev_dpad_right = dpad_right
	prev_dpad_up = dpad_up
	prev_dpad_down = dpad_down

func _handle_joystick_input():
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)

	# Horizontal
	if x_axis < -0.5 and prev_axis_x >= -0.5:
		current_button = clamp(current_button - 1, 0, buttons.size() - 1)
		_clamp_visible_button(-1)
	elif x_axis > 0.5 and prev_axis_x <= 0.5:
		current_button = clamp(current_button + 1, 0, buttons.size() - 1)
		_clamp_visible_button(1)

	# Vertical
	elif y_axis < -0.5 and prev_axis_y >= -0.5:
		current_button -= 3
		_clamp_visible_button(-3)
	elif y_axis > 0.5 and prev_axis_y <= 0.5:
		current_button += 3
		_clamp_visible_button(3)

	current_button = clamp(current_button, 0, buttons.size() - 1)

	prev_axis_x = x_axis
	prev_axis_y = y_axis

func _clamp_visible_button(direction: int) -> void:
	if buttons.size() == 0:
		return
	
	current_button = clamp(current_button, 0, buttons.size() - 1)
	var start_index = current_button
	var tries = 0
	
	while tries < buttons.size():
		if buttons[current_button].visible:
			break
		
		current_button += direction
		if current_button >= buttons.size():
			current_button = 0
		elif current_button < 0:
			current_button = buttons.size() - 1
		
		tries += 1
		
		if current_button == start_index:
			break


func _scroll_background():
	bg1.global_position.y += 5
	bg2.global_position.y += 5
	globals.current_menu_bg_pos[0] = bg1.global_position.y
	globals.current_menu_bg_pos[1] = bg2.global_position.y
	if bg1.global_position.y > 2156:
		bg1.global_position.y = -2156
	if bg2.global_position.y > 2156:
		bg2.global_position.y = -2156

func _highlight_items():
	if globals.using_gamepad:
		for i in range(buttons.size()):
			var btn = buttons[i]
			if i == current_button:
				if get_tree().get_nodes_in_group("uibutton").has(btn): btn.scale = Vector2(1.15, 1.15) 
				else: btn.scale = Vector2(1.75, 1.75)
				if btn is not Button: item_under_mouse = btn
			else:
				if get_tree().get_nodes_in_group("uibutton").has(btn): btn.scale = Vector2(1, 1) 
				else: btn.scale = Vector2(1.5, 1.5)
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	item_under_mouse = null
	for item in get_node("page" + str(page)).get_children():
		var scale_target = Vector2(1.5, 1.5)
		if is_mouse_over_item(item, mouse_pos):
			scale_target = Vector2(1.75, 1.75)
			if item.get_meta("unlocked"):
				item_under_mouse = item
		item.scale = scale_target

func _refresh_gallery():
	for page_node in get_tree().get_nodes_in_group("pages"):
		for item in page_node.get_children():
			var item_icon = null
			if item.get_child_count() > 0:
				item_icon = item.get_child(0)
			if not item_icon:
				if item is Sprite2D:
					item.texture = gallery_locked_sprite
				item.set_meta("unlocked", false)
				continue
			var unlocked = false
			var icon_name = item_icon.name.replace(" long", "")
			for minigame in globals.all_unlocked_scenes:
				if minigame.split("/")[-1].contains(icon_name):
					unlocked = true
					break
			item_icon.visible = unlocked
			if not unlocked and item is Sprite2D:
				item.texture = gallery_locked_sprite
			item.set_meta("unlocked", unlocked)

func _refresh_buttons():
	buttons.clear()
	buttons.append(button_back)
	for item in get_node("page" + str(page)).get_children():
		buttons.append(item)
	buttons.append(button_left)
	buttons.append(button_right)

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item.texture == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	return Rect2(-size * 0.5, size).has_point(local_pos)

func _on_buttonback_pressed():
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_left_pressed():
	if page == 1:
		return
	get_node("page" + str(page)).visible = false
	page -= 1
	get_node("page" + str(page)).visible = true
	if page == 1:
		button_left.hide()
	button_right.show()
	globals._play_pop()
	_refresh_buttons()

func _on_right_pressed():
	if page == max_page:
		current_button -= 1
		return
	get_node("page" + str(page)).visible = false
	page += 1
	get_node("page" + str(page)).visible = true
	if page == max_page:
		button_right.hide()
	button_left.show()
	globals._play_pop()
	_refresh_buttons()

func _on_unlockall_pressed():
	globals._play_pop()
	for hand in ["camo", "eyes", "fire", "caution", "real"]:
		globals._unlock_hands(hand)
	for game in ["Soccer"]:
		globals._unlock_minigame(game)
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_buttonback_2_mouse_entered() -> void: $buttonback.scale = Vector2(1.15,1.15) 
func _on_buttonback_mouse_exited() -> void: $buttonback.scale = Vector2(1,1) 
func _on_left_mouse_entered() -> void: $left.scale = Vector2(1.15,1.15) 
func _on_left_mouse_exited() -> void: $left.scale = Vector2(1,1) 
func _on_right_mouse_entered() -> void: $right.scale = Vector2(1.15,1.15)
func _on_right_mouse_exited() -> void: $right.scale = Vector2(1,1)
