extends Node2D

@export var shrink_time := 1.0
@export var shake_strength := 8.0
@export var shake_speed := 0.085

var shake_direction := 1

func _ready():
	_start_shake()
	await get_tree().create_timer(1.0).timeout
	_start_shrink()
	await get_tree().create_timer(1.0).timeout
	if $"../Ball" != null: $"../Ball".gravity_scale = 1

func _start_shrink():
	globals.is_playing_minigame_anim = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, shrink_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _start_shake():
	_shake_loop()

func _shake_loop() -> void:
	if scale == Vector2.ZERO:
		rotation = 0
		return
	
	var rng = RandomNumberGenerator.new()
	var angle = deg_to_rad(rng.randi_range(int(shake_strength/2), shake_strength)) * shake_direction
	rotation = angle
	
	shake_direction *= -1
	if get_tree() == null:
		return
	await get_tree().create_timer(shake_speed).timeout
	_shake_loop()
