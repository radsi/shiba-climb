extends Node

var pending_menu_messages = []

var is_on_transition = false
var is_playing_minigame_anim = false

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
var incresing_speed = false

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
var is_single_minigame = false

var audio_player: AudioStreamPlayer2D
var music_player: AudioStreamPlayer2D
var whistle_audio = preload("res://sounds/90743__pablo-f__referee-whistle.wav")
var lose_audio = preload("res://sounds/350985__cabled_mess__lose_c_02.wav")
var menu_audio = preload("res://sounds/628445__davo32__level-music-brackground.mp3")
var music_audio = preload("res://sounds/404717__djevilj__nu-break-july-2017-drum-track.wav")

func _ready():
	audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = whistle_audio
	add_child(audio_player)
	audio_player.bus = "Master"
	audio_player.volume_db = -5
	
	music_player = AudioStreamPlayer2D.new()
	music_player.stream = menu_audio
	add_child(music_player)
	music_player.bus = "Master"
	music_player.volume_db = -5
	music_player.play()

func _process(delta: float) -> void:
	if is_single_minigame and is_long:
		game_speed += delta / 2
		hands_drain_rate += delta / 2
		return
	
	if (not roll_started and not is_single_minigame) or is_on_transition or is_playing_minigame_anim:
		return
	
	if not is_single_minigame and life == 0:
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

func start_single_minigame(minigame):
	music_player.stream = music_audio
	is_single_minigame = true
	music_player.play()
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
	pool = ["res://scenes/minigames/"+minigame+".tscn"]
	last_scene = ""
	_start_roll()

func start_roll_from_menu():
	music_player.stream = music_audio
	music_player.play()
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
	if is_single_minigame and (has_lost_life or time_left <= 0):
		has_lost_life = false
		roll_started = false
		_game_over()
		return


	if pool.is_empty():
		pool = []
		for s in all_unlocked_scenes:
			if s != last_scene:
				pool.append(s)
		incresing_speed = true
		game_speed += 50
		game_time -= 1
		game_time_long += 5
		hands_drain_rate += 2.5

	if pool.is_empty():
		print("No scenes to load!")
		return

	minigame_completed = false

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

	if game_score >= 0 and not is_single_minigame and life > 0:
		is_on_transition = true
		get_tree().change_scene_to_file("res://scenes/transition.tscn")
	
	if game_score == -1: get_tree().change_scene_to_file(scene_path)
	
	game_score += 1
	
func _unlock_minigame(minigame: String):
	var scene_path = "res://scenes/minigames/"+minigame.to_lower()+".tscn"
	if all_unlocked_scenes.has(scene_path): return
	all_unlocked_scenes.push_back(scene_path)
	pending_menu_messages.push_back("Unlocked new .minigame: "+minigame+"!")

func _game_over():
	if game_score >= 4:
		_unlock_minigame("Arcade")
	
	if game_score >= 8:
		_unlock_minigame("Toast")
	
	if game_score >= 16:
		_unlock_minigame("Rope")
		
	if game_score >= 24:
		_unlock_minigame("Bonfire")
	
	if game_score >= 32:
		_unlock_minigame("Kanji")
	
	roll_started = false
	is_on_transition = false
	roll_pending = false
	has_lost_life = false
	minigame_completed = false
	is_single_minigame = false
	
	life = 3
	get_tree().change_scene_to_file("res://scenes/transition.tscn")
	await get_tree().create_timer(3).timeout
	
	audio_player.stream = lose_audio
	audio_player.play()
	audio_player.stream = whistle_audio
	is_long = false
	game_score = -1
	game_speed = 200
	game_time = 10
	game_time_long = 15
	hands_drain_rate = 5
	pool = []
	last_scene = ""
	music_player.stream = menu_audio
	music_player.play()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
