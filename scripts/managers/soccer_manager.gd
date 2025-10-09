extends Node

@onready var ball_prefab = preload("res://prefabs/soccer/soccer_ball.tscn")
@onready var hands = $CanvasGroup
@onready var kick = $kick
@onready var net = $net
@onready var cup = $SoccerCup

var balls = []
var ball_started = {}

var balls_speed = globals.game_speed / 10004
var stopped_balls = 0

var cup_animation_timer = 0.0
var cup_animation_count = 0
var cup_animation_interval = 0.5

var spawn_delay = 1.5
var spawn_timer = 0.0
var balls_spawned = false

func _ready() -> void:
	cup.visible = false

func _process(delta: float) -> void:
	if not balls_spawned:
		spawn_timer += delta
		if spawn_timer >= spawn_delay:
			_spawn_balls(4)
			balls_spawned = true
		return

	if balls.size() > 0:
		_update_ball(delta)
	else:
		_handle_cup_animation(delta)

func _update_ball(delta: float) -> void:
	var ball = balls[0]
	var target_scale = Vector2(0.04, 0.04)

	if not ball_started[ball] and ball.scale.length() > 0:
		kick.play()
		ball_started[ball] = true

	var scale_factor = ball.scale.length() / target_scale.length()
	var speed = balls_speed * (1 + scale_factor * 2)
	ball.scale += Vector2.ONE * speed * delta

	if ball.scale.x >= target_scale.x:
		ball.scale = target_scale
		if _is_hand_over_ball(ball):
			stopped_balls += 1
			if stopped_balls >= 3:
				globals.minigame_completed = true
		else:
			net.play()

		ball.queue_free()
		balls.pop_front()

func _is_hand_over_ball(ball: Sprite2D) -> bool:
	return _hand_over_ball(ball, hands.hand_left.global_position) or _hand_over_ball(ball, hands.hand_right.global_position)

func _hand_over_ball(ball: Sprite2D, hand: Vector2) -> bool:
	if hand == null:
		return false
	var local_pos = ball.to_local(hand)
	var size = ball.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	return rect.has_point(local_pos)

func _handle_cup_animation(delta: float) -> void:
	if not globals.minigame_completed:
		return
	
	if globals.is_single_minigame:
		globals.is_playing_minigame_anim = true

	cup_animation_timer += delta
	if cup_animation_timer >= cup_animation_interval:
		cup_animation_timer = 0.0
		cup.visible = true
		cup.rotation_degrees *= -1
		cup_animation_count += 1

	if cup_animation_count >= 4:
		if globals.is_single_minigame:
			globals.is_playing_minigame_anim = false
			globals.time_left = globals.game_time
			cup.visible = false
			cup_animation_count = 0
			stopped_balls = 0
			globals.minigame_completed = false
			balls_spawned = false
			spawn_timer = 0.0

func _spawn_balls(amount: int) -> void:
	for i in range(amount):
		var ball = ball_prefab.instantiate()
		ball.global_position = Vector2(randf_range(120, 960), randf_range(120, 960))
		ball.scale = Vector2.ZERO
		balls.append(ball)
		ball_started[ball] = false
		add_child(ball)
