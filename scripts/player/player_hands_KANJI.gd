extends HANDS

@onready var subvp = $"../SubViewportContainer/SubViewport"
@onready var label: Label = $"../SubViewportContainer/SubViewport/Label"
@onready var brush: Sprite2D = $"../bottle/Brush"
@onready var brush_tip: Node2D = $"../bottle/Brush/Tip"
@onready var ink_deco = $"../ink"

var brush_original_transform = {}
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

var kanji_image: Image
var draw_image: Image
var draw_tex: ImageTexture

var brush_size := 12
var can_calculate = false
var wrong_pixels: Array = []

func _ready() -> void:
	super._ready()

	brush_original_transform[0] = brush.global_position
	brush_original_transform[1] = brush.rotation_degrees

	subvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await get_tree().process_frame
	await get_tree().process_frame

	kanji_image = subvp.get_texture().get_image()
	draw_image = Image.create(kanji_image.get_width(), kanji_image.get_height(), false, Image.FORMAT_RGBA8)
	draw_image.fill(Color(1,1,1,0))
	draw_tex = ImageTexture.create_from_image(draw_image)

	var sprite = Sprite2D.new()
	sprite.texture = draw_tex
	add_child(sprite)

func _process(delta):
	super._process(delta)
	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)

	if attached_left != null or attached_right != null:
		_draw_at(brush_tip.global_position)
		can_calculate = true
	elif can_calculate:
		can_calculate = false
		var accuracy = calculate_accuracy()
		print(accuracy)
		if accuracy >= 80:
			ink_deco.show()
			globals.minigame_completed = true
			$"../pencil".play()
			if not globals.is_single_minigame:
				globals.is_playing_minigame_anim = true
				await get_tree().create_timer(2).timeout
				$".."._ready()
				globals.is_playing_minigame_anim = false
				ink_deco.hide()
				subvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
				await get_tree().process_frame
				await get_tree().process_frame

				kanji_image = subvp.get_texture().get_image()
				draw_image.fill(Color(1,1,1,0))

	_update_wrong_pixels(delta)

func update_attached_hand(attached, hand: Node2D, is_left: bool, delta: float) -> void:
	if not dragging_left and attached_left != null:
		detach_hand(hand_left, true)
	if not dragging_right and attached_right != null:
		detach_hand(hand_right, false)

	if hand == null or not hand.is_inside_tree():
		return

	if attached != null:
		if attached.is_inside_tree():
			attached.global_position = Vector2(hand.global_position.x - [30,-30][int(is_left)], hand.global_position.y - 30)
			hand.texture = globals.closehand_texture
		else:
			detach_hand(hand, is_left)

	if dragging_left and attached_left == null:
		attach_hand_to_brush(hand_left, true)
	elif dragging_right and attached_right == null:
		attach_hand_to_brush(hand_right, false)

func attach_hand_to_brush(hand: Node2D, is_left: bool) -> void:
	if brush == null or brush.texture == null or not brush.visible:
		return

	var local_pos = brush.to_local(hand.global_position)
	var size = brush.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		brush.rotation_degrees = -40
		if is_left:
			attached_left = brush
		else:
			attached_right = brush
			brush.flip_h = true
			brush.rotation_degrees = 40
		hand.texture = globals.closehand_texture

func detach_hand(hand: Node2D, is_left: bool) -> void:
	if is_left:
		attached_left = null
	else:
		attached_right = null
	if hand != null and hand.is_inside_tree():
		hand.texture = globals.openhand_texture

	brush.flip_h = false
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(brush, "global_position", brush_original_transform[0], 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween2.tween_property(brush, "rotation_degrees", brush_original_transform[1], 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _draw_at(pos: Vector2):
	var radius_sq = brush_size * brush_size
	for x in range(-brush_size, brush_size + 1):
		for y in range(-brush_size, brush_size + 1):
			if x * x + y * y <= radius_sq:
				var px = int(pos.x) + x
				var py = int(pos.y) + y
				if px >= 0 and py >= 0 and px < draw_image.get_width() and py < draw_image.get_height():
					draw_image.set_pixel(px, py, Color(0,0,0,1))

					var kc = kanji_image.get_pixel(px, py)
					var kanji_white = kc.r > 0.9 and kc.g > 0.9 and kc.b > 0.9 and kc.a > 0
					if not kanji_white:
						wrong_pixels.append({"pos": Vector2(px, py), "time": 0.0})

	draw_tex.update(draw_image)

func _update_wrong_pixels(delta: float) -> void:
	var needs_update = false
	for i in range(wrong_pixels.size() - 1, -1, -1):
		wrong_pixels[i]["time"] += delta
		if wrong_pixels[i]["time"] >= 3.0:
			var pos = wrong_pixels[i]["pos"]
			if pos.x >= 0 and pos.y >= 0 and pos.x < draw_image.get_width() and pos.y < draw_image.get_height():
				draw_image.set_pixelv(pos, Color(1,1,1,0))
				needs_update = true
			wrong_pixels.remove_at(i)
	if needs_update:
		draw_tex.update(draw_image)

func calculate_accuracy() -> float:
	if not kanji_image or not draw_image:
		return 0.0

	var w = kanji_image.get_width()
	var h = kanji_image.get_height()
	var total_white_pixels = 0
	var correct_pixels = 0

	for x in range(w):
		for y in range(h):
			var kc = kanji_image.get_pixel(x, y)
			var dc = draw_image.get_pixel(x, y)

			if kc.a < 0.1:
				continue

			var kanji_white = kc.r > 0.9 and kc.g > 0.9 and kc.b > 0.9
			var draw_black = dc.r < 0.5 and dc.g < 0.5 and dc.b < 0.5 and dc.a > 0.1

			if kanji_white:
				total_white_pixels += 1
				if draw_black:
					correct_pixels += 1

	if total_white_pixels == 0:
		return 0.0

	var accuracy = float(correct_pixels) / float(total_white_pixels) * 100.0
	return round(clamp(accuracy, 0, 100) * 100) / 100
