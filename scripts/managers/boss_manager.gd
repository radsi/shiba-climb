extends Node

var slash_color = Color("e25349ff")

@onready var hands: HANDS = $CanvasGroup

@onready var eye2_sprite = preload("res://mini games sprites/bosses/eye2.png")
@onready var eyes = [$Gas/Eye, $Gas/Eye2]
@onready var boss_sprite = $Gas
var original_positions = []

@onready var valve = $Valve
@onready var valve_tube = $Valve/RedTube
@onready var valve_object = $Valve/Valve
@onready var valve_anim: AnimationPlayer = $"Valve/AnimationPlayer"
@onready var valve_smokes = [$"Valve/smoke1", $"Valve/smoke2", $"Valve/smoke3", $"Valve/smoke4"]

@onready var vendor = $Vendor
@onready var vendor_label = $Vendor/Label

@onready var slash_sfx = $slash
@onready var explosion_sfx = $explosionsfx
@onready var wrong_sfx = $wrong

@onready var explosions = $explosions
@onready var explosion = $explosion

@onready var slashes = [$Slash1, $Slash2, $Slash3, $Slash4]
var random_events = []

var can_hit_wall := true
var doing_attack := false

var wall_hp := 11
var boss_hp := 2

var hand_input := ""
var timer: float = 0

func _ready() -> void:
	globals.minigame_completed = true
	original_positions = [
		boss_sprite.global_position,
		eyes[0].global_position,
		eyes[1].global_position
	]
	random_events = [Callable(self, "enable_valve"), Callable(self, "enable_vendor")]
	_apply_random_transform()
	do_attacks()

func _process(delta: float) -> void:
	if vendor.visible:
		if hand_input == vendor_label.text:
			disable_vendor()
		elif not vendor_label.text.begins_with(hand_input):
			blink_text()

	if (valve.visible or vendor.visible):
		timer += delta
		if ((timer >= 15 and valve.visible) or (timer >= 25 and vendor.visible)) and globals.minigame_completed:
			die()

	if wall_hp == 6 and can_hit_wall:
		wall_hp -= 1
		can_hit_wall = false
		if random_events.size() > 0:
			var event = randi() % random_events.size()
			random_events[event].call()
			random_events.remove_at(event)

func _apply_random_transform() -> void:
	if boss_hp <= 0:
		return
	for i in range(eyes.size()):
		var eye = eyes[i]
		var base_pos = original_positions[1 + i]
		eye.global_position = base_pos + Vector2(randf_range(-4, 4), randf_range(-4, 4))
	await get_tree().create_timer(0.1).timeout
	_apply_random_transform()

func blink_text() -> void:
	wrong_sfx.play()
	for i in range(2):
		vendor_label.hide()
		await get_tree().create_timer(0.1).timeout
		vendor_label.show()
		await get_tree().create_timer(0.1).timeout
	hand_input = ""

func do_attacks():
	if boss_hp <= 0:
		return
	await get_tree().create_timer(randf_range(3, 5)).timeout
	var slashes_group = slashes[randi_range(0, slashes.size() - 1)]
	for slash in slashes_group.get_children():
		slash.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(slash, "modulate", slash_color, 1 / (globals.game_speed / 300))
		if slash.name.contains("3"):
			tween.finished.connect(func(): await _on_attack_tween_finished(slashes_group))
	do_attacks()

func _on_attack_tween_finished(slashes_group):
	for slash in slashes_group.get_children():
		for area in slash.get_child(0).get_overlapping_areas():
			if area.name == "Areahand" and not hands.block_left_hand_movement and not hands.block_right_hand_movement:
				die()
	slash_sfx.play()
	doing_attack = true
	await get_tree().create_timer(0.5).timeout
	for slash in slashes_group.get_children():
		slash.modulate = Color(1, 1, 1, 0)
	doing_attack = false

func die():
	if eyes[0].visible == false:
		return
	globals.minigame_completed = false
	explosion.show()
	explosion.play()
	explosion_sfx.play()
	await get_tree().create_timer(1).timeout
	globals.has_lost_life = true
	globals.life -= 1
	globals._start_roll()

func _kill_boss():
	globals._unlock_hands("eyes")
	for _explosion: AnimatedSprite2D in explosions.get_children():
		await get_tree().create_timer(0.5).timeout
		explosion_sfx.play()
		_explosion.show()
		_explosion.play()
	eyes[0].hide()
	eyes[1].hide()
	await get_tree().create_timer(2).timeout
	globals._start_roll()

func enable_valve():
	valve.show()
	var tween = create_tween()
	var tween2 = create_tween()
	tween2.tween_property(valve_object, "global_position", Vector2(540, 630), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(valve_tube, "global_position", Vector2(540, 1400), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_valve_moved").bind(false))

func disable_valve():
	can_hit_wall = true
	timer = 0
	var tween = create_tween()
	var tween2 = create_tween()
	tween2.tween_property(valve_object, "position", Vector2(540, 899), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(valve_tube, "position", Vector2(540, 1669), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_valve_moved").bind(true))

func _on_valve_moved(disable):
	valve_anim.seek(0)
	valve_anim.play("smoke")
	for i in range(valve_smokes.size()):
		valve_smokes[i].visible = not disable
	if disable:
		valve.hide()

func enable_vendor():
	vendor.show()
	var chars = "0123456789ABCD"
	vendor_label.text = ""
	for i in range(5):
		vendor_label.text += chars[randi_range(0, chars.length() - 1)]
	var tween = create_tween()
	tween.tween_property(vendor, "global_position", Vector2(0, -630), 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_vendor_moved").bind(false))

func disable_vendor():
	hand_input = ""
	can_hit_wall = true
	timer = 0
	var tween = create_tween()
	tween.tween_property(vendor, "global_position", Vector2(0, 0), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_vendor_moved").bind(true))

func _on_vendor_moved(disable):
	if disable:
		vendor.hide()
