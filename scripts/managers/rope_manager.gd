extends Node

@onready var rope = $Rope
@onready var girl_hand = $Rope/GirlHand
@onready var girl_hand_hearts = $Rope/GirlHand/Hearts
var smooch_played = false
var timer = 0
var hearts_original_positions = {}
var rope_original_pos

func _ready() -> void:
	rope_original_pos = rope.global_position

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.5:
		timer = 0
		for heart in girl_hand_hearts.get_children():
			if not hearts_original_positions.has(heart.name): hearts_original_positions[heart.name] = heart.position
			_apply_random_transform(heart)
	
	if girl_hand.global_position.y >= 180: 
		globals.minigame_completed = true
		if not smooch_played: 
			$smooch.play() 
			smooch_played = true
			if globals.is_single_minigame:
				globals.is_playing_minigame_anim = true
				globals.time_left = globals.game_time
				await get_tree().create_timer(1.5).timeout
				globals.is_playing_minigame_anim = false
				rope.global_position = rope_original_pos
				smooch_played = false
		return
	rope.global_position.y -= globals.game_speed / 100

func _apply_random_transform(deco: Sprite2D) -> void:
	var base_pos = hearts_original_positions[deco.name]
	deco.position = base_pos + Vector2(
		randf_range(-10, 10),
		randf_range(-10, 10)
	)
	deco.rotation_degrees = randf_range(0, 45)
	var new_scale = randf_range(0.25, 0.5)
	deco.scale = Vector2(new_scale, new_scale)
