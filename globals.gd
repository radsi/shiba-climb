extends Node

var difficult_tier = 1

var username = ""
var pending_score = false

var using_gamepad = false
var hands_color = Color(1,1,1)

var pending_menu_messages = []
var current_menu_bg_pos = [0.0, 0.0]

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
var fingerhand_texture = preload("res://hand sprites/finger hand.png")
var clapped_texture = preload("res://hand sprites/palm hand_clapped.png")
var winhand_texture = preload("res://hand sprites/win hands.png")
var gohand_texture = preload("res://hand sprites/up hand.png")
var skin = ""

var all_unlocked_scenes := [
	"res://scenes/minigames/apples.tscn",
	"res://scenes/minigames/clean.tscn",
	"res://scenes/minigames/climb long.tscn"
]

var all_unlocked_hands := [
	"default",
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
var boss_music_audio = preload("res://sounds/boss music.wav")
var pop_audio = preload("res://sounds/pop-sound-effect.wav")

func _play_pop():
	audio_player.stream = pop_audio
	audio_player.play()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_gamepad = true
	else:
		using_gamepad = false

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
		
	if time_left <= 0 and not is_single_minigame:
		if has_lost_life == false and is_long == false and minigame_completed == false: 
			life -= 1
			has_lost_life = true
		_start_roll()
	
	if (life == 0 and has_lost_life) or (time_left <= 0 and is_single_minigame):
		_game_over()
		return

	time_left -= delta

func start_single_minigame(minigame):
	music_player.stream = music_audio
	audio_player.stream = whistle_audio
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
	audio_player.stream = whistle_audio
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
	game_score = -1
	_start_roll()

func _start_roll():
	
	if game_score % 4 == 0:
		incresing_speed = true
		game_speed += 50
		game_time -= 1
		game_time_long += 5
		hands_drain_rate += 2.5
	
	if pool.is_empty():
		pool = []
		for s in all_unlocked_scenes:
			if s != last_scene:
				pool.append(s)

	if pool.is_empty():
		print("No scenes to load!")
		return

	minigame_completed = false

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var index := rng.randi_range(0, pool.size() - 1)
	var scene_path: String = pool[index]

	last_scene = scene_path
	if last_scene == "res://scenes/minigames/pingpong.tscn":
		last_scene = "res://scenes/minigames/pingpong long.tscn"
	elif last_scene == "res://scenes/minigames/samurai.tscn":
		last_scene = "res://scenes/minigames/samurai long.tscn"
	pool.remove_at(index)
	
	if last_scene.contains("boss"):
		music_player.stop()
		music_player.stream = boss_music_audio
		music_player.play()
	elif music_player.stream == boss_music_audio:
		music_player.stop()
		music_player.stream = music_audio
		music_player.play()

	if last_scene.contains("long"):
		is_long = true
		minigame_completed = true
		time_left = game_time_long
	else:
		is_long = false
		time_left = game_time

	if game_score >= 0 and not is_single_minigame and life > 0:
		is_on_transition = true
		get_tree().change_scene_to_file("res://scenes/transition.tscn")
	
	if game_score == -1: get_tree().change_scene_to_file(last_scene)
	
	game_score += 1
	
func _unlock_minigame(minigame: String, with_message = true):
	var scene_path = "res://scenes/minigames/"+minigame.to_lower()+".tscn"
	if all_unlocked_scenes.has(scene_path): return
	all_unlocked_scenes.push_back(scene_path)
	if with_message: pending_menu_messages.push_back("Unlocked new .minigame: "+minigame+"!")
	
func _unlock_hands(hands: String, with_message = true):
	if all_unlocked_hands.has(hands): return
	all_unlocked_hands.push_back(hands)
	if with_message: pending_menu_messages.push_back("Unlocked new .hands: "+hands+"!")

func _game_over():
	has_lost_life = false
	
	if is_single_minigame == false:
		pending_score = true
	
	if game_score >= 4:
		_unlock_minigame("Arcade")
		_unlock_minigame("Toast")
		_unlock_hands("hearts")
	
	if game_score >= 8:
		_unlock_hands("camo")
		
	if game_score >= 10:
		_unlock_minigame("Rope")
		_unlock_hands("caution")
		
	if game_score >= 15:
		_unlock_minigame("Bonfire")
		_unlock_hands("fire")
	
	if game_score >= 20:
		_unlock_minigame("Kanji")
		_unlock_hands("dalmata")
	
	if game_score >= 30:
		_unlock_minigame("Soccer")
	
	if all_unlocked_scenes.size() >= 17:
		_unlock_minigame("Boss")
	
	roll_started = false
	is_on_transition = false
	roll_pending = false
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
