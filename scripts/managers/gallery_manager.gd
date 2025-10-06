extends Node

@onready var gallery_locked_sprite = preload("res://gallery item locked.png")
var item_under_mouse: Sprite2D = null
var max_page = 1
var page = 1
@onready var bg1 = $Bg
@onready var bg2 = $Bg2

func _ready() -> void:
	bg1.global_position.y = globals.current_menu_bg_pos[0]
	bg2.global_position.y = globals.current_menu_bg_pos[1]
	max_page = get_tree().get_nodes_in_group("pages").size()
	$AnimationPlayer.play("arrow_green")
	$AnimationPlayer2.play("arrow_back")
	for page in get_tree().get_nodes_in_group("pages"):
		for item in page.get_children():
			var item_icon = null
			if item.get_child_count() > 0:
				item_icon = item.get_child(0)

			if item_icon == null:
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


func _process(delta: float) -> void:
	bg1.global_position.y += 5
	bg2.global_position.y += 5
	
	globals.current_menu_bg_pos[0] = bg1.global_position.y
	globals.current_menu_bg_pos[1] = bg2.global_position.y
	
	if bg1.global_position.y > 2156:
		bg1.global_position.y = -2156
	if bg2.global_position.y > 2156:
		bg2.global_position.y = -2156
		
	var mouse_pos = get_viewport().get_mouse_position()
	item_under_mouse = null

	for item in get_node("page"+str(page)).get_children():
		var scale_target = Vector2(1.5, 1.5)
		if is_mouse_over_item(item, mouse_pos):
			scale_target = Vector2(1.75, 1.75)
			if item.get_meta("unlocked"): item_under_mouse = item
		item.scale = scale_target


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and item_under_mouse != null:
		var icon = item_under_mouse.get_child(0)
		if icon != null:
			globals.start_single_minigame(icon.name)

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item.texture == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	return rect.has_point(local_pos)

func _on_buttonback_pressed() -> void:
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_buttonback_2_mouse_entered() -> void:
	$buttonback.scale = Vector2(1.15,1.15)


func _on_buttonback_mouse_exited() -> void:
	$buttonback.scale = Vector2(1,1)


func _on_left_mouse_entered() -> void:
	$left.scale = Vector2(1.15,1.15)

func _on_left_mouse_exited() -> void:
	$left.scale = Vector2(1,1)

func _on_right_mouse_entered() -> void:
	$right.scale = Vector2(1.15,1.15)

func _on_right_mouse_exited() -> void:
	$right.scale = Vector2(1,1)

func _on_left_pressed() -> void:
	if page == 1: return
	get_node("page"+str(page)).visible = false
	page -= 1
	get_node("page"+str(page)).visible = true
	if page == 1: $left.hide()
	$right.visible = true
	globals._play_pop()

func _on_right_pressed() -> void:
	if page == max_page: return
	get_node("page"+str(page)).visible = false
	page += 1
	get_node("page"+str(page)).visible = true
	if page == max_page: $right.hide()
	$left.visible = true
	globals._play_pop()


func _on_unlockall_pressed() -> void:
	globals._play_pop()
	globals._unlock_hands("camo")
	globals._unlock_minigame("Arcade")
	globals._unlock_minigame("Toast")
	globals._unlock_minigame("Rope")
	globals._unlock_minigame("Bonfire")
	globals._unlock_minigame("Jail")
	globals._unlock_minigame("Kanji")
	globals._unlock_minigame("Candle")
	globals._unlock_minigame("PingPong")
	globals._unlock_minigame("Vendor")
	globals._unlock_hands("eyes")
	globals._unlock_hands("fire")
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
