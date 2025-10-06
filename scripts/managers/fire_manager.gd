extends Node

@onready var fire = $bonfire/fire
@onready var fire_sprites = [
	preload("res://mini games sprites/fire/fire1.png"),
	preload("res://mini games sprites/fire/fire2.png"),
	preload("res://mini games sprites/fire/fire3.png")
]

var played_audio = false
var timer: float = 0

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.5:
		fire.texture = fire_sprites[0]
	if timer >= 1:
		fire.texture = fire_sprites[1]
	if timer >= 1.5:
		fire.texture = fire_sprites[2]
		timer = 0
		
	if fire.scale.x >= 0.6:
		if not played_audio:
			globals.minigame_completed = true
			$AudioStreamPlayer2D.play()
			played_audio = true
			if globals.is_single_minigame:
				globals.is_playing_minigame_anim = true
				await get_tree().create_timer(2).timeout
				$AudioStreamPlayer2D.stop()
				globals.is_playing_minigame_anim = true
				globals.time_left = globals.game_time
				fire.scale = Vector2(0.25, 0.25)
		return
	elif fire.scale.x <= 0:
		if not played_audio:
			$AudioStreamPlayer2D2.play()
			played_audio = true
		return
		
	fire.scale.x -= globals.game_speed / 100000
	fire.scale.y -= globals.game_speed / 100000
