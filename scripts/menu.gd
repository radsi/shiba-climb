extends Control

var showing_messages = false
var active_icon

static var first_time = true
var clapped = false

var message_timer = 0

@onready var palm = $PalmHand

func _ready() -> void:
	
	if first_time:
		if $VSplitContainer/Button3: $VSplitContainer/Button3.hide()
	
	if $AnimationPlayer2 != null:
		$AnimationPlayer2.play("arrow_back")
	
	if $AnimationPlayer != null:
		$AnimationPlayer.seek(0, true)
		$AnimationPlayer.play("mainmenu")
	
	if globals.pending_menu_messages.size() > 0:
		_show_pending_message()

func _process(delta: float) -> void:
	if message_timer >= 2:
		return
	
	message_timer += delta

func _input(event) -> void:
	if event is InputEventMouseButton:
		if showing_messages and message_timer >= 2: _close_message()
	
	if showing_messages or message_timer < 1: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if _is_mouse_over_palm(mouse_pos) and clapped == false:
			$AudioStreamPlayer2D.play()
			palm.texture = globals.clapped_texture
			var tween = create_tween()
			tween.tween_property($ColorRect, "color:a", 1.0, 1.0)
			tween.tween_callback(Callable(self, "_on_fade_complete"))
			first_time = false
			clapped = true

func _is_mouse_over_palm(pos: Vector2) -> bool:
	if palm is Sprite2D and palm.texture != null:
		var size = palm.texture.get_size() * palm.scale
		var rect = Rect2(palm.global_position - size * 0.5, size)
		return rect.has_point(pos)
	return false

func _on_fade_complete() -> void:
	get_tree().change_scene_to_file("res://scenes/countdown.tscn")

func _on_button_2_pressed() -> void:
	if showing_messages or message_timer < 1: return
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_buttonback_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_3_pressed() -> void:
	if showing_messages or message_timer < 1: return
	get_tree().change_scene_to_file("res://scenes/gallery.tscn")

func _show_pending_message():
	showing_messages = true
	var message = $Message
	var icons = $Message/Icons
	var colorrect = $ColorRect
	
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
	$ColorRect.modulate.a = 0
	$Message.visible = false


func _on_buttonback_mouse_entered() -> void:
	if $buttonback != null:
		$buttonback.scale = Vector2(1.15,1.15)


func _on_buttonback_mouse_exited() -> void:
	if $buttonback != null:
		$buttonback.scale = Vector2(1,1)
