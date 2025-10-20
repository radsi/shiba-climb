extends Node

var slash_color = Color("e25349ff")

@onready var eyes = [$Gas/Eye, $Gas/Eye2]
@onready var boss_sprite = $Gas
var original_positions = [null, null, null]

@onready var valve_tube = $Valve/RedTube
@onready var valve_object = $Valve/Valve
@onready var valve_animation = $"Valve/AnimationPlayer"
@onready var valve_anim: AnimationPlayer = $"Valve/AnimationPlayer"
@onready var valve_smokes = [$"Valve/smoke1", $"Valve/smoke2", $"Valve/smoke3", $"Valve/smoke4"]

@onready var slash_sfx = $slash
@onready var explosion_sfx = $explosionsfx

@onready var explosions = $explosions
@onready var explosion = $explosion

@onready var slashes = [$Slash1, $Slash2, $Slash3, $Slash4]
var random_events = [Callable(self, "enable_valve")]

var valve_active := false
var can_hit_wall := true
var doing_attack := false

var wall_hp := 10
var boss_hp := 2

var timer: float = 0

func _ready() -> void:
	globals.minigame_completed = true
	original_positions[0] = boss_sprite.global_position
	original_positions[1] = eyes[0].global_position
	original_positions[2] = eyes[1].global_position
	_apply_random_transform()
	do_attacks()

func _process(delta: float) -> void:
	if valve_active:
		timer += delta
		if timer >= 10 and globals.minigame_completed == true:
			explosion.show()
			return
	
	if can_hit_wall == false: return
	
	match(wall_hp):
		5:
			randomize()
			can_hit_wall = false
			var event = randi_range(0, random_events.size()-1)
			random_events[event].call()


func _apply_random_transform() -> void:
	for i in range(eyes.size()):
		var eye = eyes[i]
		var base_pos = original_positions[1+i]
		eye.global_position = base_pos + Vector2(
			randf_range(-4, 4),
			randf_range(-4, 4)
		)
	await get_tree().create_timer(0.1).timeout
	_apply_random_transform()


func do_attacks():
	await get_tree().create_timer(randf_range(3, 5)).timeout
	var slashes_group = slashes[randi_range(0, slashes.size()-1)]
	for slash in slashes_group.get_children():
		slash.modulate = Color(1, 1, 1, 0)
		var tween = get_tree().create_tween()
		tween.tween_property(slash, "modulate", slash_color, 1 / (globals.game_speed / 300))
		if not slash.name.contains("3"): continue
		tween.finished.connect(func():
			await _on_attack_tween_finished(slashes_group)
		)
	do_attacks()

func _on_attack_tween_finished(slashes_group):
	for slash in slashes_group.get_children():
		for area in slash.get_child(0).get_overlapping_areas():
			if area.name == "Areahand":
				print("hand die")
	
	slash_sfx.play()
	doing_attack = true
	await get_tree().create_timer(0.5).timeout
	for slash in slashes_group.get_children():
		slash.modulate = Color(1, 1, 1, 0)

	doing_attack = false

func _kill_boss():
	for explosion in explosions.get_children():
		await get_tree().create_timer(0.5).timeout
		explosion_sfx.play()
		explosion.show()
	
	globals.minigame_completed = true

func enable_valve():
	var tween = create_tween()
	var tween2 = create_tween()
	tween2.tween_property(valve_object, "global_position", Vector2(540, 630), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(valve_tube, "global_position", Vector2(540, 1400), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_valve_moved"))
	
func disable_valve():
	can_hit_wall = true
	valve_active = false
	for i in range(4):
		valve_smokes[i].hide()
	valve_anim.stop()
	valve_anim.seek(0)
	
	var tween = create_tween()
	var tween2 = create_tween()
	tween2.tween_property(valve_object, "position", Vector2(540, 899), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(valve_tube, "position", Vector2(540, 1669), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_valve_moved():
	valve_active = true
	for i in range(4):
		valve_smokes[i].show()
	valve_anim.play("smoke")
