extends Control

static var first_time = true
var clapped = false
var clapped_texture = preload("res://palm hand_clapped.png")
@onready var palm = $PalmHand

func _ready() -> void:
	$AnimationPlayer.seek(0, true)
	$AnimationPlayer.play("mainmenu")

	if first_time == false:
		$ColorRect.color.a = 1
		var tween = create_tween()
		tween.tween_property($ColorRect2, "color:a", 0.0, 1.0)

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if _is_mouse_over_palm(mouse_pos) and clapped == false:
			$AudioStreamPlayer2D.play()
			palm.texture = clapped_texture
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
	globals.start_roll_from_menu()

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_buttonback_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
