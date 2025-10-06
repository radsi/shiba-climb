extends Node

@onready var hands = $Current
@onready var gallery_locked_sprite = preload("res://gallery item locked.png")
var item_under_mouse: Sprite2D = null
var max_page = 1
var page = 1

@onready var bg1 = $Bg
@onready var bg2 = $Bg2

func _ready() -> void:
	max_page = get_tree().get_nodes_in_group("pages").size()
	$AnimationPlayer.play("arrow_green")
	$AnimationPlayer2.play("arrow_back")
	for page in get_tree().get_nodes_in_group("pages"):
		for item in page.get_children():
			var item_icon = null
			if item.get_child_count() > 0 and globals.all_unlocked_hands.has(item.name):
				item.set_meta("unlocked", true)
			elif not globals.all_unlocked_hands.has(item.name):
				if item.get_child_count() > 0:
					item.get_child(0).hide()
					item.get_child(1).hide()
				item.set_meta("unlocked", false)
				item.texture = gallery_locked_sprite

func _process(delta: float) -> void:
	
	bg1.global_position.y += 5
	bg2.global_position.y += 5
	
	if bg1.global_position.y > 2156:
		bg1.global_position.y = -2156
	if bg2.global_position.y > 2156:
		bg2.global_position.y = -2156
	
	globals.current_menu_bg_pos[0] = bg1.global_position.y
	globals.current_menu_bg_pos[1] = bg2.global_position.y
	
	item_under_mouse = null
	for item in get_node("page"+str(page)).get_children():
		var scale_target = Vector2(1.5, 1.5)
		if is_mouse_over_item(item, get_viewport().get_mouse_position()):
			scale_target = Vector2(1.75, 1.75)
			if item.get_meta("unlocked"): item_under_mouse = item
		item.scale = scale_target

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and item_under_mouse != null:
		hands.get_child(0).texture = item_under_mouse.get_child(0).texture
		globals.openhand_texture = item_under_mouse.get_child(0).texture
		hands.get_child(1).texture = item_under_mouse.get_child(1).texture
		globals.closehand_texture = item_under_mouse.get_child(1).texture
		var texture_name = hands.get_child(0).texture.get_path().get_file()
		if texture_name.contains("_"):
			var skin = texture_name.split("_")[1]
			globals.fingerhand_texture = load("res://hand sprites/finger hand_" + skin)
			globals.winhand_texture = load("res://hand sprites/win hands_" + skin)
			globals.gohand_texture = load("res://hand sprites/up hand_" + skin)
		else:
			globals.fingerhand_texture = load("res://hand sprites/finger hand.png")
			globals.winhand_texture = load("res://hand sprites/win hands.png")
			globals.gohand_texture = load("res://hand sprites/up hand.png")
		globals._play_pop()

func _on_buttonback_pressed() -> void:
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_marker_color_changed(value: int, id: StringName) -> void:
	match str(id):
		"R":
			globals.hands_color.r = value / 255.0
		"G":
			globals.hands_color.g = value / 255.0
		"B":
			globals.hands_color.b = value / 255.0
	
	hands.modulate = globals.hands_color

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item.texture == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	return rect.has_point(local_pos)

func _on_buttonback_mouse_entered() -> void:
	$buttonback.scale = Vector2(1.15,1.15)

func _on_buttonback_mouse_exited() -> void:
	$buttonback.scale = Vector2(1,1)

func _on_left_pressed() -> void:
	if page == 1: return
	get_node("page"+str(page)).visible = false
	page -= 1
	get_node("page"+str(page)).visible = true
	if page == 1: $left.hide()
	$right.visible = true
	globals._play_pop()

func _on_left_mouse_exited() -> void:
	$left.scale = Vector2(1,1)

func _on_left_mouse_entered() -> void:
	$left.scale = Vector2(1.15,1.15)

func _on_right_pressed() -> void:
	if page == max_page: return
	get_node("page"+str(page)).visible = false
	page += 1
	get_node("page"+str(page)).visible = true
	if page == max_page: $right.hide()
	$left.visible = true
	globals._play_pop()

func _on_right_mouse_exited() -> void:
	$right.scale = Vector2(1,1)

func _on_right_mouse_entered() -> void:
	$right.scale = Vector2(1.15,1.15)
