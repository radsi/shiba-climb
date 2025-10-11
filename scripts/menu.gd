extends Control

var showing_messages = false
var active_icon

static var first_time = true
var clapped = false

var message_timer = 0

@onready var palm = $PalmHand
@onready var ok = $Message/CanvasGroup/LikeHand
@onready var custom_button = $CustomIcon
@onready var gallery_button = $GalleryIcon
@onready var leaderboard_button = $LeaderboardIcon
@onready var bg1 = $Bg
@onready var bg2 = $Bg2
@onready var message = $Message
@onready var icons = $Message/Icons
@onready var colorrect = $ColorRect

var prev_dpad_left := false
var prev_dpad_right := false
var prev_dpad_up := false
var prev_dpad_down := false
var prev_axis_x := 0.0
var prev_axis_y := 0.0
var editing_username = false

@onready var buttons = [leaderboard_button, gallery_button, palm, custom_button]
var current_button = 2

func _ready() -> void:
	
	if globals.username == "" and globals.pending_score:
		colorrect.color.a = 0.75
		editing_username = true
		message.show()
		message.get_child(2).show()
		message.get_child(0).text = "What's your name??"
	
	
	if globals.current_menu_bg_pos[0] > 0:
		bg1.global_position.y = globals.current_menu_bg_pos[0]
		bg2.global_position.y = globals.current_menu_bg_pos[1]
	
	if $AnimationPlayer2 != null:
		$AnimationPlayer2.play("arrow_back")
	
	if $AnimationPlayer != null:
		$AnimationPlayer.seek(0, true)
		$AnimationPlayer.play("mainmenu")
		
	if $"animation custom button" != null:
		$"animation custom button".play("custom_button")
	
	if globals.pending_menu_messages.size() > 0 and not globals.pending_score:
		_show_pending_message()

func _process(delta: float) -> void:
	if globals.username != "" and globals.pending_score:
		globals.pending_score = false
		await Talo.players.identify("username", globals.username)
		await Talo.leaderboards.add_entry("handware-leaderboard", globals.game_score, {
			"skin": globals.skin
		})
	
	# --- D-PAD ---
	var dpad_left = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT)
	var dpad_right = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT)
	var dpad_up = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP)
	var dpad_down = Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN)
	
	if dpad_left and not prev_dpad_left and not editing_username:
		current_button = clamp(current_button + 1, 0, buttons.size()-1)
	elif dpad_right and not prev_dpad_right and not editing_username:
		current_button = clamp(current_button - 1, 0, buttons.size()-1)
	elif dpad_up and not prev_dpad_up and not editing_username:
		current_button = 2
	elif dpad_down and not prev_dpad_down and not editing_username:
		current_button = 0
	
	prev_dpad_left = dpad_left
	prev_dpad_right = dpad_right

	# --- JOYSTICK IZQUIERDO ---
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	if x_axis < -0.5 and prev_axis_x >= -0.5 and not editing_username:
		current_button = clamp(current_button + 1, 0, buttons.size()-1)
	elif x_axis > 0.5 and prev_axis_x <= 0.5 and not editing_username:
		current_button = clamp(current_button - 1, 0, buttons.size()-1)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	if y_axis < -0.5 and prev_axis_y >= -0.5 and not editing_username:
		current_button = 2
	elif y_axis > 0.5 and prev_axis_y <= 0.5 and not editing_username:
		current_button = 0
	
	prev_axis_x = x_axis
	prev_axis_y = y_axis
	
	bg1.global_position.y += 5
	bg2.global_position.y += 5
	
	if bg1.global_position.y > 2156:
		bg1.global_position.y = -2156
	if bg2.global_position.y > 2156:
		bg2.global_position.y = -2156
	
	globals.current_menu_bg_pos[0] = bg1.global_position.y
	globals.current_menu_bg_pos[1] = bg2.global_position.y
	
	if is_mouse_over_item(custom_button, get_viewport().get_mouse_position()) or (current_button == 1 and globals.using_gamepad):
		custom_button.scale = Vector2(1.25, 1.25)
	else:
		if custom_button != null: custom_button.scale = Vector2(1, 1)
	
	if is_mouse_over_item(palm, get_viewport().get_mouse_position()) or (current_button == 2 and globals.using_gamepad):
		palm.scale = Vector2(3.5, 3.5)
	else:
		if palm != null: palm.scale = Vector2(3, 3)
	
	if is_mouse_over_item(gallery_button, get_viewport().get_mouse_position()) or (current_button == 3 and globals.using_gamepad):
		gallery_button.scale = Vector2(1.25, 1.25)
	else:
		if gallery_button != null: gallery_button.scale = Vector2(1, 1)
	
	if is_mouse_over_item(leaderboard_button, get_viewport().get_mouse_position()) or (current_button == 0 and globals.using_gamepad):
		leaderboard_button.scale = Vector2(1.05, 1.05)
	else:
		if leaderboard_button != null: leaderboard_button.scale = Vector2(0.8, 0.8)
	
	if (is_mouse_over_item(ok, get_viewport().get_mouse_position()) or (current_button == 2 and globals.using_gamepad)):
		ok.scale = Vector2(2.25, 2.25)
	else:
		if ok != null: ok.scale = Vector2(2, 2)
	
	if message_timer >= 2:
		return
	
	message_timer += delta

func _input(event) -> void:
	if event is InputEventMouseButton:
		if showing_messages and message_timer >= 2: _close_message()
	
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B and get_tree().current_scene.name != "Menu":
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return
	
	if ((event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A)) and event.pressed:
		if (is_mouse_over_item(ok, get_viewport().get_mouse_position()) or (current_button == 2 and globals.using_gamepad)) and editing_username:
			globals.pending_score = false
			var text_node = message.get_child(2).get_child(0)
			var text = text_node.text.strip_edges().replace("\n", "")
			if text == "":
				return
			globals._play_pop()
			globals.username = text
			_close_message()
			if globals.pending_menu_messages.size() > 0 and not globals.pending_score: _show_pending_message()
	
		if showing_messages or message_timer < 0.5 or editing_username or clapped: return
		
		if (is_mouse_over_item(palm, get_viewport().get_mouse_position()) or (current_button == 2 and globals.using_gamepad)):
			$AudioStreamPlayer2D.play()
			palm.texture = globals.clapped_texture
			var tween = create_tween()
			tween.tween_property(colorrect, "modulate:a", 1.0, 1.0)
			tween.tween_callback(Callable(self, "_on_fade_complete"))
			first_time = false
			clapped = true
		elif (is_mouse_over_item(custom_button, get_viewport().get_mouse_position()) or (current_button == 1 and globals.using_gamepad)):
			globals._play_pop()
			get_tree().change_scene_to_file("res://scenes/customization.tscn")
		elif (is_mouse_over_item(gallery_button, get_viewport().get_mouse_position()) or (current_button == 3 and globals.using_gamepad)):
			globals._play_pop()
			get_tree().change_scene_to_file("res://scenes/gallery.tscn")
		elif (is_mouse_over_item(leaderboard_button, get_viewport().get_mouse_position()) or (current_button == 0 and globals.using_gamepad)):
			globals._play_pop()
			get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var _size = item.texture.get_size()
	var rect = Rect2(-_size * 0.5, _size)
	return rect.has_point(local_pos)

func _on_fade_complete() -> void:
	get_tree().change_scene_to_file("res://scenes/countdown.tscn")

func _on_button_2_pressed() -> void:
	if showing_messages or message_timer < 1 or editing_username: return
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _show_pending_message():
	return
	showing_messages = true
	
	$clapping.play()
	colorrect.color.a = 0.75
	message.visible = true
	message.get_child(0).text = globals.pending_menu_messages[0]
	
	var regex = RegEx.new()
	regex.compile(r":\s*(.+)")
	var text_match = regex.search(globals.pending_menu_messages[0])

	if text_match:
		var result = text_match.get_string(1)
		var clean_regex = RegEx.new()
		clean_regex.compile(r"[^a-zA-Z0-9 ]")
		result = clean_regex.sub(result, "").strip_edges()
		print(result)
		if icons.has_node(result):
			active_icon = icons.get_node(result)
			active_icon.visible = true
	
	globals.pending_menu_messages.remove_at(0)

func _close_message():
	message_timer = 0
	if active_icon != null: active_icon.visible = false
	
	if globals.pending_menu_messages.size() > 0:
		_show_pending_message()
		return
	
	showing_messages = false
	editing_username = false
	colorrect.modulate.a = 0
	$Message.visible = false

func _on_buttonback_pressed() -> void:
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_buttonback_mouse_entered() -> void:
	if $buttonback != null:
		$buttonback.scale = Vector2(1.15,1.15)


func _on_buttonback_mouse_exited() -> void:
	if $buttonback != null:
		$buttonback.scale = Vector2(1,1)


func _on_username_text_changed() -> void:
	var t = message.get_child(2).get_child(0)
	if t.text.length() > 17:
		t.text = t.text.substr(0, 17)
		t.set_caret_column(t.text.length())
