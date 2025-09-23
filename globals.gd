extends Node

var game_speed := 200
var game_time := 10
var game_time_long := 10
var life := 3
var time_left

var minigame_folder := "res://scenes/minigames/"
var all_scenes := []
var pool := []
var last_scene := ""

func _ready():
	_load_all_scenes()

# Carga todas las escenas del folder
func _load_all_scenes():
	var dir = DirAccess.open(minigame_folder)
	if dir == null:
		print("Cannot open folder: ", minigame_folder)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			all_scenes.append(minigame_folder + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	pool = all_scenes.duplicate()

func _game_over():
	game_speed += 200
	game_time = 10
	game_time_long = 15
	
	_load_all_scenes()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _start_roll():
	if pool.is_empty():
		# Refill pool excluyendo la última escena
		pool = []
		for s in all_scenes:
			if s != last_scene:
				pool.append(s)
		game_speed += 50
		game_time -= 1
		game_time_long += 5
		print("New roll! Speed:", game_speed, "Time:", game_time)
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var index := rng.randi_range(0, pool.size() - 1)
	var scene_path: String = pool[index]
	
	last_scene = scene_path
	get_tree().change_scene_to_file(scene_path)
	if scene_path.contains("long"):
		time_left = game_time_long
	else:
		time_left = game_time
	
	pool.remove_at(index)
