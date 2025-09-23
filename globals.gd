extends Node

var game_speed: float = 200
var game_time: float = 10
var game_time_long: float = 10
var life: int = 3
var time_left: float = 10
var minigame_completed := false
var has_lost_life := false
var roll_started := false
var is_long := false

var minigame_folder := "res://scenes/minigames/"
var all_scenes := []
var pool := []
var last_scene := ""
var roll_pending := false  # <-- controla que solo se haga un roll por evento

func _ready():
	_load_all_scenes()

func _process(delta: float) -> void:
	if not roll_started:
		return

	if life <= 0:
		_game_over()
		return

	time_left -= delta

	if time_left <= 0 or (has_lost_life and not roll_pending):
		if not minigame_completed and not has_lost_life:
			has_lost_life = true
			life -= 1
		roll_pending = true
		_start_roll()  # solo se llamará una vez por roll
		roll_pending = false

func start_roll_from_menu():
	game_speed = 200
	game_time = 10
	game_time_long = 10
	life = 3
	time_left = game_time
	minigame_completed = false
	has_lost_life = false
	roll_started = true
	is_long = false
	pool = all_scenes.duplicate()
	_start_roll()

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

func _start_roll():
	if life <= 0:
		_game_over()
		return

	# Refill pool excluyendo la última escena
	if pool.is_empty():
		pool = []
		for s in all_scenes:
			if s != last_scene:
				pool.append(s)
		game_speed += 50
		game_time -= 1
		game_time_long += 5

	if pool.is_empty():
		print("No scenes to load!")
		return

	minigame_completed = false
	has_lost_life = false

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var index := rng.randi_range(0, pool.size() - 1)
	var scene_path: String = pool[index]

	last_scene = scene_path
	pool.remove_at(index)  # <-- eliminar antes de cargar la escena para no repetir

	if scene_path.contains("long"):
		is_long = true
		time_left = game_time_long
	else:
		is_long = false
		time_left = game_time

	get_tree().change_scene_to_file(scene_path)

func _game_over():
	is_long = false
	game_speed += 50
	game_time = 10
	game_time_long = 15
	life = 3
	minigame_completed = false
	roll_started = false
	_load_all_scenes()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
