extends Node

func _ready():
	var children = get_children()
	if children.size() <= 7:
		return
	
	children.shuffle()
	for i in range(4):
		var child = children[i]
		if child is Node:
			child.visible = false

func _process(delta):
	var children = get_children()
	for apple in children:
		if apple is Node2D and apple.is_inside_tree():
			if apple.global_position.distance_to($"../Basket".global_position) < 64:
				apple.queue_free()

	var all_invisible = true
	for child in children:
		if child is Node and child.visible:
			all_invisible = false
			break

	if all_invisible:
		globals.minigame_completed = true
