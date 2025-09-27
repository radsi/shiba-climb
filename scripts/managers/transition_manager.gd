extends Node

@onready var up_hand_sprite = preload("res://hand sprites/up hand.png")

@onready var text = $CanvasGroup/message
@onready var hands = $CanvasGroup/hands
@onready var bg = $Bg
@onready var decorations_list = [$decorations1, $decorations2, $decorations3, $decorations4]
@onready var decorations = decorations_list[randf_range(0, decorations_list.size())]
var timer = 0
var original_positions := {}

var colors = ["#F8FAB4", "#91ADC8", "#D9E9CF", "#A376A2"]
var bg_colors = ["#8FA31E", "#003161", "#D1D3D4"]
var messages_bad = ["Too bad!", "You can do better", "Oh..."] 
var messages_good = ["Nice!", "Very good!", "Good hand play"] 

func _ready() -> void:
	bg.modulate = Color(bg_colors[randf_range(0, bg_colors.size())])
	text.rotation_degrees = 6
	hands.rotation_degrees = -6
	decorations.visible = true
	for deco: Sprite2D in decorations.get_children():
		original_positions[deco] = deco.global_position
		deco.modulate = Color(colors[randf_range(0, colors.size())])
		_apply_random_transform(deco)
	
	if globals.incresing_speed:
		text.text = "Go go go!"
		hands.texture = up_hand_sprite
		$speed.play()
		return
	
	if globals.has_lost_life:
		text.text = messages_bad[randf_range(0, messages_bad.size())]
		hands.flip_v = true
		$bad.play()
	else:
		text.text = messages_good[randf_range(0, messages_good.size())]
		$good.play()

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= 0.5:
		timer = 0
		for deco: Sprite2D in decorations.get_children():
			_apply_random_transform(deco)
		text.rotation_degrees *= -1
		hands.rotation_degrees *= -1

func _apply_random_transform(deco: Sprite2D) -> void:
	var base_pos = original_positions[deco]
	deco.global_position = base_pos + Vector2(
		randf_range(-20, 20),
		randf_range(-20, 20)
	)
	deco.rotation_degrees = randf_range(0, 360)
	var new_scale = randf_range(0.5, 1.25)
	deco.scale = Vector2(new_scale, new_scale)
