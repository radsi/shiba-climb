extends HANDS

@onready var dirty_objects: Node = $"../BlackTshirt/Dirty"
@onready var scrub_sound: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

var transparency_step: float = 0.05
var old_transparency := {}

func _ready() -> void:
	grappling = true
	super._ready()

	for obj in dirty_objects.get_children():
		if obj is Sprite2D:
			old_transparency[obj] = obj.modulate.a

func _input(event: InputEvent) -> void:
	super._input(event)

func _process(delta: float) -> void:
	super._process(delta)

	if globals.is_playing_minigame_anim: return

	var changed := false
	if hand_left == null or hand_right == null: return
	changed = increase_transparency_under_hand(hand_left, last_pos_left) or changed
	changed = increase_transparency_under_hand(hand_right, last_pos_right) or changed

	if dragging_left:
		last_pos_left = hand_left.global_position
	if dragging_right:
		last_pos_right = hand_right.global_position

	if changed and not scrub_sound.playing:
		scrub_sound.play()

func increase_transparency_under_hand(hand: Sprite2D, last_pos: Vector2) -> bool:
	if hand == null or hand.visible == false or hand.texture != globals.openhand_texture:
		return false

	var delta_pos = hand.global_position - last_pos
	var movement_threshold = 1.0
	if delta_pos.length() < movement_threshold:
		return false

	var any_changed := false
	for obj in dirty_objects.get_children():
		if obj is Sprite2D and obj.texture:
			var local_pos: Vector2 = obj.to_local(hand.global_position)
			var tex_size: Vector2 = obj.texture.get_size()
			var rect: Rect2 = Rect2(-tex_size * 0.5, tex_size)

			if rect.has_point(local_pos):
				var c: Color = obj.modulate
				var new_alpha: float = clamp(c.a - transparency_step, 0.0, 1.0)

				if new_alpha < c.a:
					c.a = new_alpha
					obj.modulate = c
					old_transparency[obj] = new_alpha
					any_changed = true
	return any_changed
