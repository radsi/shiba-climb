extends Sprite2D

@onready var size = texture.get_size()
@onready var rect = Rect2(-size * 0.5, size)
@onready var id = str(get_parent().name)[get_parent().name.length() - 1]
@onready var manager = $"../../.."

var min_pos : float
var max_pos : float
var fixed_y : float
var dragging := false

@export var mapped_value: int = 0

signal color_changed(value: int, id: String)

func _ready() -> void:
	var parent_tex_size = get_parent().get_child(0).texture.get_size().x
	min_pos = global_position.x - parent_tex_size * 0.5 + 30
	max_pos = global_position.x + parent_tex_size * 0.5 - 30
	fixed_y = global_position.y

	$"../../../Current".modulate = globals.hands_color

	match id:
		"R":
			mapped_value = int(globals.hands_color.r * 255)
		"G":
			mapped_value = int(globals.hands_color.g * 255)
		"B":
			mapped_value = int(globals.hands_color.b * 255)

	var t = 1.0 - float(mapped_value) / 255.0
	global_position.x = lerp(min_pos, max_pos, t)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_DPAD_LEFT:
			if manager.buttons[manager.current_button] == self:
				_change_value(5)
		elif event.button_index == JOY_BUTTON_DPAD_RIGHT:
			if manager.buttons[manager.current_button] == self:
				_change_value(-5)
		
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_mouse = to_local(get_viewport().get_mouse_position())
				if rect.has_point(local_mouse):
					dragging = true
			else:
				dragging = false

func _process(delta: float) -> void:
	if dragging:
		var mouse_x = get_viewport().get_mouse_position().x
		var clamped_x = clamp(mouse_x, min_pos, max_pos)
		global_position = Vector2(clamped_x, fixed_y)

		var t = 1.0 - (global_position.x - min_pos) / (max_pos - min_pos)
		mapped_value = int(round(t * 255))

		emit_signal("color_changed", mapped_value, id)

func _change_value(amount: int) -> void:
	mapped_value = clamp(mapped_value + amount, 0, 255)
	var t = 1.0 - float(mapped_value) / 255.0
	global_position.x = lerp(min_pos, max_pos, t)
	emit_signal("color_changed", mapped_value, id)
