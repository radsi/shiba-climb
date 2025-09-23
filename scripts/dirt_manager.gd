extends Node

func _ready():
	var children = get_children()
	children.shuffle()

	for i in range(min(9, children.size())):
		var child = children[i]
		if child is Node2D or child is Control:
			child.hide()

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for child in children:
		if child is Node2D:
			child.rotation = deg_to_rad(rng.randi_range(0, 360))

func _process(delta):
	var all_max_transparent = true
	
	for child in get_children():
		if (child is Node2D or child is Control) and child.visible:
			var modulate_color = child.modulate if "modulate" in child else null
			if modulate_color != null and modulate_color.a > 0:
				all_max_transparent = false
				break
	
	if all_max_transparent:
		print("Todos los hijos visibles han llegado a transparencia máxima")
