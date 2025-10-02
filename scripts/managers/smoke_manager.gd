extends Node

var fire
@onready var fire_sprites = [
	preload("res://mini games sprites/smoke/fire1.png"),
	preload("res://mini games sprites/smoke/fire2.png"),
	preload("res://mini games sprites/smoke/fire3.png")
]
@onready var candle_tips = [
	$Candle/Tip,
	$Candle2/Tip,
	$Candle3/Tip
]

var lighted_tips = {"Candle": false, "Candle2": false, "Candle3":false}

var candle_played_flags = []

var timer = 0.0
var original_match_transform = {}

@onready var matches = $Matches
@onready var _match = $Matches/Match
@onready var slide_sfx = $slide

var last_match_pos: Vector2
var move_timer := 0.0
var slide_played := false
var slide_count = 0

func _ready() -> void:
	fire = $Matches/Match.get_child(0)
	original_match_transform[0] = _match.global_position
	original_match_transform[1] = _match.rotation_degrees
	
	for i in candle_tips.size():
		candle_played_flags.append(false)

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.5:
		fire.texture = fire_sprites[0]
		for tip in candle_tips:
			tip.get_parent().get_child(1).texture = fire_sprites[0]
	if timer >= 1:
		fire.texture = fire_sprites[1]
		for tip in candle_tips:
			tip.get_parent().get_child(1).texture = fire_sprites[2]
	if timer >= 1.5:
		fire.texture = fire_sprites[2]
		for tip in candle_tips:
			tip.get_parent().get_child(1).texture = fire_sprites[1]
		timer = 0
	
	if _match.get_parent() == matches:
		var local_pos = matches.to_local(_match.global_position)
		var size = matches.texture.get_size()
		var rect = Rect2(-size * 0.5, size)
		if _match.global_position != last_match_pos and rect.has_point(local_pos):
			move_timer += delta
			if move_timer >= 0.3 and not slide_played and slide_count < 3:
				slide_sfx.play()
				slide_played = true
				slide_count += 1
				await get_tree().create_timer(0.2).timeout
				move_timer = 0
				slide_played = false
		else:
			move_timer = 0.0
			slide_played = false
	else:
		move_timer = 0.0
		slide_played = false
	
	if slide_count >= 3:
		_match.get_child(0).show()

	last_match_pos = _match.global_position

	if fire.visible:
		for i in range(candle_tips.size()):
			var tip = candle_tips[i]
			if fire.global_position.distance_to(tip.global_position) < 12:
				var candle_fire = tip.get_parent().get_child(1)
				candle_fire.show()
				lighted_tips[tip.get_parent().name] = true
				if lighted_tips["Candle"] != true or lighted_tips["Candle2"] != true or lighted_tips["Candle3"] != true:
					return
				globals.minigame_completed = true
				
				if not candle_played_flags[i]:
					$candle.play()
					candle_played_flags[i] = true

				if globals.is_single_minigame:
					globals.is_playing_minigame_anim = true
					await get_tree().create_timer(1.5).timeout
					move_timer = 0
					slide_count = 0
					slide_played = false
					globals.is_playing_minigame_anim = false
					globals.time_left = globals.game_time
					candle_fire.hide()
					fire.hide()
					_match.z_index = -1
					_match.global_position = original_match_transform[0]
					_match.rotation_degrees = original_match_transform[1]
					lighted_tips = {"Candle": false, "Candle2": false, "Candle3":false}
					
					for x in range(candle_tips.size()):
						candle_tips[x].get_parent().get_child(1).hide()
				break
