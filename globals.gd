extends Node

var pending_menu_messages = []

var game_score: int = -1
var game_speed: float = 200
var game_time: float = 10
var game_time_long: float = 10
var life: int = 3
var time_left: float = 10
var minigame_completed := false
var has_lost_life := false
var roll_started := false
var is_long := false
var roll_pending := false

var hands_max_durability = 20
var hands_drain_rate: float = 5
var openhand_texture = preload("res://hand sprites/open hand.png")
var closehand_texture = preload("res://hand sprites/fist hand.png")
var clapped_texture = preload("res://hand sprites/palm hand_clapped.png")

var all_unlocked_scenes := [
	"res://scenes/minigames/apples.tscn",
	"res://scenes/minigames/clean.tscn",
	"res://scenes/minigames/climb long.tscn"
]
var pool := []
var last_scene := ""

var audio_player: AudioStreamPlayer2D
var whistle_audio = preload("res://sounds/90743__pablo-f__referee-whistle.wav")
var lose_audio = preload("res://sounds/350985__cabled_mess__lose_c_02.wav")

func _ready():
	audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = whistle_audio
	add_child(audio_player)
	audio_player.bus = "Master"
	audio_player.volume_db = -5

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
		call_deferred("_start_roll")
		roll_pending = false

func start_roll_from_menu():
	audio_player.play()
	game_speed = 200
	game_time = 10
	game_time_long = 10
	life = 3
	time_left = game_time
	minigame_completed = false
	has_lost_life = false
	roll_started = true
	is_long = false
	pool = all_unlocked_scenes.duplicate()
	last_scene = ""
	_start_roll()

func _start_roll():
	if life <= 0:
		_game_over()
		return

	if pool.is_empty():
		pool = []
		for s in all_unlocked_scenes:
			if s != last_scene:
				pool.append(s)
		game_speed += 50
		game_time -= 1
		game_time_long += 5
		hands_drain_rate += 2.5

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
	pool.remove_at(index)

	if scene_path.contains("long"):
		is_long = true
		minigame_completed = true
		time_left = game_time_long
	else:
		is_long = false
		time_left = game_time

	#get_tree().change_scene_to_file("res://scenes/transition.tscn")
	game_score += 1
	#await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file(scene_path)

func play_whistle():
	audio_player.stream = whistle_audio
	audio_player.play()
	
func _unlock_minigame(minigame: String):
	var scene_path = "res://scenes/minigames/"+minigame.to_lower()+".tscn"
	if all_unlocked_scenes.has(scene_path): return
	all_unlocked_scenes.push_back(scene_path)
	pending_menu_messages.push_back("Unlocked new .minigame: "+minigame+"!")

func _game_over():
	if game_score >= 4:
		_unlock_minigame("Arcade")
	
	audio_player.stream = lose_audio
	audio_player.play()
	audio_player.stream = whistle_audio
	is_long = false
	game_score = -1
	game_speed = 200
	game_time = 10
	game_time_long = 15
	life = 3
	minigame_completed = false
	roll_started = false
	pool = all_unlocked_scenes.duplicate()
	last_scene = ""
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
