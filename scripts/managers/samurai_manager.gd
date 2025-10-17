extends Node

@onready var samurai_sprites = [
	preload("res://mini games sprites/samurai 1.png"),
	preload("res://mini games sprites/samurai 2.png")
]
@onready var samurais = [$Samurai1, $Samurai2]
@onready var slashes = [$Samurai1/ColorRect, $Samurai2/ColorRect]

var doing_attacks = false
var max_rot = -60
var min_rot = -200

var slash_color = Color("e25349ff")
var slashing = false
var hand_can_die = false

func _ready() -> void:
	globals.is_playing_minigame_anim = true

func _process(delta: float) -> void:
	if globals.is_playing_minigame_anim or globals.has_lost_life == true: return
	
	print(hand_can_die)

	if slashing and hand_can_die and globals.has_lost_life == false:
		$hit.play()
		globals.has_lost_life = true
		await get_tree().create_timer(0.5).timeout
		if globals.is_single_minigame:
			globals._game_over()
		else:
			globals.life -= 1
			globals._start_roll()

	if doing_attacks == false:
		do_attack()

func is_sprite_over_texture_rect(sprite: Sprite2D, texture_rect: TextureRect) -> bool:
	if sprite == null or texture_rect == null:
		return false

	var sprite_rect = Rect2(
		sprite.global_position - sprite.texture.get_size() * 0.5,
		sprite.texture.get_size()
	)

	var tr_global_pos = texture_rect.global_position - texture_rect.size * 0.5
	var tr_rect = Rect2(tr_global_pos, texture_rect.size)

	return sprite_rect.intersects(tr_rect)

func do_attack():
	doing_attacks = true

	var hand_left_pos = $CanvasGroup.hand_left.global_position
	var hand_right_pos = $CanvasGroup.hand_right.global_position

	var dir = hand_left_pos - samurais[0].global_position
	slashes[0].rotation_degrees = rad_to_deg(dir.angle()) - 90

	var dir2 = hand_right_pos - samurais[1].global_position
	slashes[1].rotation_degrees = rad_to_deg(dir2.angle()) - 90

	slashes[0].modulate = Color(1, 1, 1, 0)
	slashes[1].modulate = Color(1, 1, 1, 0)
	
	if get_tree() == null: return
	
	var tween1 = get_tree().create_tween()
	tween1.tween_property(slashes[0], "modulate", slash_color, 1 / (globals.game_speed / 200))
	var tween2 = get_tree().create_tween()
	tween2.tween_property(slashes[1], "modulate", slash_color, 1 / (globals.game_speed / 200))

	tween2.finished.connect(func():
		await _on_samurai_tween_finished()
	)

func _on_samurai_tween_finished() -> void:
	for i in range(2):
		samurais[i].texture = samurai_sprites[1]
	$slash.play()
	slashing = true
	await get_tree().create_timer(0.5).timeout
	slashing = false
	for i in range(2):
		slashes[i].modulate = Color(1, 1, 1, 0)
		samurais[i].texture = samurai_sprites[0]

	doing_attacks = false

func _on_areahand_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "Areahand": hand_can_die = true

func _on_areahand_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "Areahand": hand_can_die = false

func _on_samurai_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "Area2D": hand_can_die = true

func _on_samurai_area_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "Area2D": hand_can_die = false
