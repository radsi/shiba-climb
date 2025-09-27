extends Node

@onready var gallery_items = $items
@onready var gallery_locked_sprite = preload("res://gallery item locked.png")
var item_under_mouse: Sprite2D = null

func _ready() -> void:
	for item in gallery_items.get_children():
		var item_icon = item.get_child(0)
		if item_icon == null:
			continue

		var unlocked = false
		var icon_name = item_icon.name
		for minigame in globals.all_unlocked_scenes:
			if minigame.split("/")[-1].contains(icon_name):
				unlocked = true
				break

		item_icon.visible = unlocked
		if not unlocked:
			item.texture = gallery_locked_sprite

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	item_under_mouse = null

	for item in gallery_items.get_children():
		var item_icon = item.get_child(0)
		if item_icon == null or not item_icon.visible:
			item.scale = Vector2(1.5, 1.5)
			continue

		var scale_target = Vector2(1.5, 1.5)
		if is_mouse_over_item(item, mouse_pos):
			item_under_mouse = item
			scale_target = Vector2(1.75, 1.75)
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
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
