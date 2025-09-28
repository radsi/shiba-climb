extends Node

@onready var stars = $"../Stars"

const ALPHA_THRESHOLD := 0.1
const RESET_COOLDOWN_TIME := 0.25

var reset_cooldown := 0.0
var timer = 0
var stars_original_pos = {}

func _ready() -> void:
	_set_dirt()

func _process(delta: float) -> void:
	if reset_cooldown > 0.0:
		reset_cooldown = max(0.0, reset_cooldown - delta)

	var all_max_transparent := true

	for child in get_children():
		if not (child is Node2D or child is Control):
			continue

		if not child.visible:
			continue

		if "modulate" in child:
			if child.modulate.a > ALPHA_THRESHOLD:
				all_max_transparent = false
				break
		else:
			all_max_transparent = false
			break

	if all_max_transparent and reset_cooldown == 0.0:
		globals.minigame_completed = true
		if globals.is_single_minigame:
			_set_dirt()
			globals.time_left = globals.game_time
			reset_cooldown = RESET_COOLDOWN_TIME
		else:
			stars.visible = true
			timer += delta
			if timer >= 0.5:
				timer = 0
				for star in stars.get_children():
					if not stars_original_pos.has(star): stars_original_pos[star.name] = star.global_position
					_apply_random_transform(star)

func _set_dirt() -> void:
	var children := get_children().duplicate()
	children.shuffle()

	for child in children:
		if child is Node:
			child.visible = true
			if "modulate" in child:
				var m = child.modulate
				m.a = 1.0
				child.modulate = m

	var to_hide = min(8, children.size())
	for i in range(to_hide):
		var c = children[i]
		if c is Node:
			c.hide()

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for child in children:
		if child is Node2D:
			child.rotation = deg_to_rad(rng.randi_range(0, 360))

func _apply_random_transform(deco: Sprite2D) -> void:
	var base_pos = stars_original_pos[deco.name]
	deco.global_position = base_pos + Vector2(
		randf_range(-20, 20),
		randf_range(-20, 20)
	)
	deco.rotation_degrees = randf_range(0, 360)
	var new_scale = randf_range(0.5, 2.25)
	deco.scale = Vector2(new_scale, new_scale)
