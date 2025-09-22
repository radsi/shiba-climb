extends Node

@onready var head = $"../../RigidBody2D_Head"
@onready var hand_left = $"Hand1"
@onready var hand_right = $"Hand2"

var openhand_texture = preload("res://open hand.png")
var closehand_texture = preload("res://fist hand.png")

var dragging_left = false
var dragging_right = false
var offset_left = Vector2.ZERO
var offset_right = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_mouse_over(hand_left, event.position):
					dragging_left = true
					hand_left.texture = openhand_texture
					offset_left = hand_left.global_position - event.position
			else:
				dragging_left = false
				hand_left.texture = closehand_texture

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if is_mouse_over(hand_right, event.position):
					dragging_right = true
					hand_right.texture = openhand_texture
					offset_right = hand_right.global_position - event.position
			else:
				dragging_right = false
				hand_right.texture = closehand_texture

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()

	if dragging_left:
		hand_left.global_position = mouse_pos + offset_left
		

	if dragging_right:
		hand_right.global_position = mouse_pos + offset_right
		

# Helper function to check if mouse is over a sprite
func is_mouse_over(sprite: Sprite2D, mouse_pos: Vector2) -> bool:
	var tex_size = sprite.texture.get_size() * sprite.scale
	var rect = Rect2(sprite.global_position - tex_size / 2, tex_size)
	return rect.has_point(mouse_pos)
