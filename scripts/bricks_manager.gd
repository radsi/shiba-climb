extends Node

var brick_scenes := []
var spawn_interval = 1.0
var brick_speed = globals.game_speed
var brick_lifetime = 20.0
var timer = 0.0
var min_distance = 50.0
var max_attempts = 10

func _ready():
	var dir = DirAccess.open("res://prefabs/bricks/")
	if dir != null:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				brick_scenes.append(load("res://prefabs/bricks/" + file_name))
			file_name = dir.get_next()
		dir.list_dir_end()

var spawn_delay = 0.5

func _process(delta):
	# Actualización de todos los bricks ya existentes
	for brick in get_children():
		brick.position.y += brick_speed * delta
		if not brick.has_meta("age"):
			brick.set_meta("age", 0.0)
		brick.set_meta("age", brick.get_meta("age") + delta)
		if brick.get_meta("age") >= brick_lifetime:
			brick.queue_free()

	# Contador para empezar a spawnear
	if spawn_delay > 0:
		spawn_delay -= delta
		return

	timer -= delta
	if timer <= 0:
		timer = spawn_interval
		spawn_brick()



func spawn_brick():
	if brick_scenes.size() == 0:
		return

	var viewport_size = get_viewport().get_visible_rect().size
	var instance_scene = brick_scenes[randi() % brick_scenes.size()]
	var instance = instance_scene.instantiate()

	var pos = Vector2.ZERO
	var valid_pos = false
	var attempts = 0

	while not valid_pos and attempts < max_attempts:
		pos = Vector2(
			randf_range(0, viewport_size.x),
			randf_range(-viewport_size.y * 0.5, 0)
		)
		valid_pos = true
		for existing in get_children():
			if pos.distance_to(existing.position) < min_distance:
				valid_pos = false
				break
		attempts += 1

	instance.position = pos
	instance.set_meta("age", 0.0)
	add_child(instance)
