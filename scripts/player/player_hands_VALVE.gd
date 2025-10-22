extends HANDS

@onready var valve = $"../Valve"

var old_mouse_pos := Vector2.ZERO

func _ready():
	super._ready()
	old_mouse_pos = get_local_mouse_position()
	
func _process(delta):
	super._process(delta)
	if valve.rotation_degrees >= 1500 and globals.minigame_completed != true:
		globals.minigame_completed = true
		$"../AnimationPlayer".stop()
		$"../smoke1".hide()
		$"../smoke2".hide()
		$"../smoke3".hide()
		if globals.is_single_minigame:
			globals.is_playing_minigame_anim = true
			globals.time_left = globals.game_time
			await get_tree().create_timer(2).timeout
			globals.minigame_completed = false
			globals.is_playing_minigame_anim = false
			$"../smoke1".show()
			$"../smoke2".show()
			$"../smoke3".show()
			$"../AnimationPlayer".play("smoke")
			valve.rotation_degrees = 0
		return
	
	var current_mouse_pos = get_local_mouse_position()
	
	if is_mouse_over_item(valve, hand_left.global_position) and dragging_left and hand_left.visible == true:
		if (hand_left.global_position.x != last_pos_left.x and globals.using_gamepad) or (current_mouse_pos.x != old_mouse_pos.x and not globals.using_gamepad):
			valve.rotate(0.1)
			if $"../valve".is_playing() == false: $"../valve".play()

	if is_mouse_over_item(valve, hand_right.global_position) and dragging_right and hand_right.visible == true:
		if (hand_right.global_position.x != last_pos_right.x and globals.using_gamepad) or (current_mouse_pos.x != old_mouse_pos.x and not globals.using_gamepad):
			valve.rotate(0.1)
			if $"../valve".is_playing() == false: $"../valve".play()

	old_mouse_pos = current_mouse_pos

func _input(event):
	super._input(event)

func is_mouse_over_item(item: Sprite2D, mouse_pos: Vector2) -> bool:
	if item == null:
		return false
	var local_pos = item.to_local(mouse_pos)
	var size = item.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	return rect.has_point(local_pos)
