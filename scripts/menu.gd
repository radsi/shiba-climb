extends Control

static var first_time = true

func _ready() -> void:
	if first_time == false:
		$ColorRect2.color.a = 1
		var tween = create_tween()
		tween.tween_property($ColorRect2, "color:a", 0, 1)

func _on_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect2, "color:a", 1.2, 1)
	tween.tween_callback(Callable(self, "_on_fade_complete"))
	first_time = false

func _on_fade_complete() -> void:
	# to do start game
	return

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_buttonback_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
