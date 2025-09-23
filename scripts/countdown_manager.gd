extends Node

@export var colors = ["F75270", "EF9595", "F7CAC9"]
@export var start_count := 4

var count := start_count

func _ready():
	$ColorRect2.color.a = 1
	var tween = create_tween()
	tween.tween_property($ColorRect2, "color:a", 0.0, 1.0)
	await get_tree().create_timer(1.0).timeout
	$AudioStreamPlayer2D.play()
	_start_countdown()

func _start_countdown():
	if count <= 1:
		globals.start_roll_from_menu()
		return
	count -= 1
	$Label.add_theme_font_size_override("font_size", 204 + (start_count - count) * 30)
	$Label.text = str(count)
	$AudioStreamPlayer2D.play()
	$ColorRect.color = Color(colors[(start_count - count - 1)])
	
	await get_tree().create_timer(1.0).timeout
	_start_countdown()
