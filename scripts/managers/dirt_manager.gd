extends Node

func _ready() -> void:
	_set_dirt()

func _process(delta: float) -> void:
	for child in get_children():
		if (child is Node2D or child is Control) and child.visible and "modulate" in child:
			if child.modulate.a > 0.1:
				return 

	globals.minigame_completed = true

func _set_dirt() -> void:
	var children = get_children().duplicate()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	children.shuffle()

	for child in children:
		if child is Node2D or child is Control:
			child.visible = true

	for i in range(min(8, children.size())):
		var child = children[i]
		if child is Node2D or child is Control:
			child.hide()

	for child in children:
		if child is Node2D:
			child.rotation = deg_to_rad(rng.randi_range(0, 360))
