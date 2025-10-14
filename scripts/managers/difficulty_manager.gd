extends Control

@onready var bg1 = $Bg
@onready var bg2 = $Bg2
@onready var colorrect = $ColorRect
@onready var buttonback = $buttonback
@onready var normal_button = $elements/diff1
@onready var grip_button = $elements/diff2
@onready var loose_button = $elements/diff3
@onready var onehand_button = $elements/diff4

var prev_dpad_left := false
var prev_dpad_right := false
var prev_dpad_up := false
var prev_dpad_down := false
var prev_axis_x := 0.0
var prev_axis_y := 0.0
var editing_username = false

@onready var buttons = {1: normal_button, 2: grip_button, 3: loose_button, 4: onehand_button}
var current_button = 2

func _ready() -> void:
	if globals.current_menu_bg_pos[0] > 0:
		bg1.global_position.y = globals.current_menu_bg_pos[0]
		bg2.global_position.y = globals.current_menu_bg_pos[1]
	if $AnimationPlayer2 != null:
		$AnimationPlayer2.play("arrow_back")
		
	get_node("elements/diff"+str(globals.difficult_tier)).get_child(1).show()

func _process(delta: float) -> void:
	# --- D-PAD ---
	var dpad_left = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT)
	var dpad_right = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT)
	var dpad_up = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP)
	var dpad_down = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN)

	if not editing_username:
		if dpad_left and not prev_dpad_left:
			current_button = clamp(current_button + 1, 1, buttons.size())
		elif dpad_right and not prev_dpad_right:
			current_button = clamp(current_button - 1, 1, buttons.size())
		elif dpad_up and not prev_dpad_up:
			current_button = clamp(current_button + 1, 1, buttons.size())
		elif dpad_down and not prev_dpad_down:
			current_button = clamp(current_button - 1, 1, buttons.size())

	prev_dpad_left = dpad_left
	prev_dpad_right = dpad_right
	prev_dpad_up = dpad_up
	prev_dpad_down = dpad_down

	# --- JOYSTICK IZQUIERDO ---
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)

	if not editing_username:
		if x_axis < -0.5 and prev_axis_x >= -0.5:
			current_button = clamp(current_button + 1, 1, buttons.size())
		elif x_axis > 0.5 and prev_axis_x <= 0.5:
			current_button = clamp(current_button - 1, 1, buttons.size())
		if y_axis < -0.5 and prev_axis_y >= -0.5:
			current_button = clamp(current_button + 1, 1, buttons.size())
		elif y_axis > 0.5 and prev_axis_y <= 0.5:
			current_button = clamp(current_button - 1, 1, buttons.size())

	prev_axis_x = x_axis
	prev_axis_y = y_axis

	# --- Background scrolling ---
	bg1.global_position.y += 5
	bg2.global_position.y += 5
	if bg1.global_position.y > 2156:
		bg1.global_position.y = -2156
	if bg2.global_position.y > 2156:
		bg2.global_position.y = -2156
	globals.current_menu_bg_pos[0] = bg1.global_position.y
	globals.current_menu_bg_pos[1] = bg2.global_position.y

	# --- Button scaling ---
	for key in buttons.keys():
		var button = buttons[key]
		if button != null:
			if is_mouse_over_item(button, get_viewport().get_mouse_position()) or (current_button == key and globals.using_gamepad):
				button.scale = Vector2(1.05, 1.05)
			else:
				button.scale = Vector2(1, 1)
	
	if current_button == 0 and globals.using_gamepad:
		$buttonback.scale = Vector2(1.15,1.15)
	else:
		$buttonback.scale = Vector2(1,1)

func _input(event) -> void:
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B and event.pressed:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return

	if ((event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) 
		or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A and event.pressed)):
		for key in buttons.keys():
			var button = buttons[key]
			if button != null:
				button.get_child(1).hide()
				if is_mouse_over_item(button, get_viewport().get_mouse_position()) or (current_button == key and globals.using_gamepad):
					globals.difficult_tier = key
					button.get_child(1).show()
					globals._play_pop()

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item == null or item.texture == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	return rect.has_point(local_pos)

func _on_fade_complete() -> void:
	get_tree().change_scene_to_file("res://scenes/countdown.tscn")


func _on_buttonback_pressed() -> void:
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_buttonback_mouse_entered() -> void:
	$buttonback.scale = Vector2(1.15,1.15)

func _on_buttonback_mouse_exited() -> void:
	$buttonback.scale = Vector2(1,1)
