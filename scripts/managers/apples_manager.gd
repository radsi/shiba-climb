extends Node

@onready var basket_full_sprite = preload("res://mini games sprites/basket full.png")
@onready var basket = $"../Basket"

var all_invisible = false

var original_positions = {}

func _ready():
	_set_apples()

func _process(delta):
	var children = get_children()
	for apple in children:
		if not original_positions.has(apple.name): original_positions[apple.name] = apple.global_position
		if apple is Node2D and apple.is_inside_tree():
			if apple.global_position.distance_to(basket.global_position) < 64:
				$"../basket".play()
				apple.visible = false
				apple.global_position = original_positions[apple.name]

	all_invisible = true
	for child in children:
		if child is Node and child.visible:
			all_invisible = false
			break

	if all_invisible:
		globals.minigame_completed = true
		if not globals.is_single_minigame: basket.texture = basket_full_sprite
		else: 
			_set_apples()
			globals.time_left = globals.game_time

func _set_apples():
	all_invisible = false
	var children = get_children()
	children.shuffle()
	
	for child in children:
		child.visible = true
	
	for i in range(4):
		var child = children[i]
		if child is Node:
			child.visible = false
