extends Node

@onready var basket = $"../Basket"

func _ready() -> void:
	_set_apples()

func _process(delta: float) -> void:
	var basket_pos = basket.global_position
	var all_invisible = true

	for apple in get_children():
		if apple is Node2D and apple.is_inside_tree():
			if apple.global_position.distance_to(basket_pos) < 64:
				apple.queue_free()
				continue

		if apple is Node and apple.visible:
			all_invisible = false

	if all_invisible:
		globals.minigame_completed = true

func _set_apples() -> void:
	var children = get_children().duplicate()
	children.shuffle()

	for i in range(children.size()):
		var child = children[i]
		if child is Node:
			child.visible = i >= 4
