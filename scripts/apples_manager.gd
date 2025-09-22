extends Node

func _ready():
	var children = get_children()
	if children.size() <= 7:
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var picked = []
	while picked.size() < 4:
		var index = rng.randi_range(0, children.size() - 1)
		if not picked.has(index):
			picked.append(index)
	
	for i in picked:
		var child = children[i]
		if child is Node:
			child.visible = false

func _process(delta):
	var children = get_children()
	for apple in children:
		if apple is Node2D and apple.is_inside_tree():
			if apple.global_position.distance_to($"../Basket".global_position) < 32: # Ajusta según tamaño del cesto
				apple.queue_free()
