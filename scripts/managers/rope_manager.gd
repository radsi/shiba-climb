extends Node

@onready var rope = $Rope
@onready var girl_hand = $Rope/GirlHand
@onready var girl_hand_hearts = $Rope/GirlHand/Hearts
var smooch_played = false
var timer = 0
var hearts_original_positions = {}

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.5:
		timer = 0
		for heart in girl_hand_hearts.get_children():
			if not hearts_original_positions.has(heart.name): hearts_original_positions[heart.name] = heart.position
			_apply_random_transform(heart)
	
	if girl_hand.global_position.y >= 180: 
		if not smooch_played: 
			$smooch.play() 
			smooch_played = true
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
