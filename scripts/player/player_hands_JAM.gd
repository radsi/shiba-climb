extends HANDS

@onready var knife: Sprite2D = $"../Knife"
@onready var knife_jam: Sprite2D = $"../Knife/KinfeJam"
@onready var toast: Sprite2D = $"../Toast"
var knife_original_transform = {}
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

var last_knife_pos: Vector2

func _ready():
	super._ready()
	knife_original_transform[0] = knife.global_position
	knife_original_transform[1] = knife.rotation_degrees
	last_knife_pos = knife_jam.global_position

func _process(delta):
	super._process(delta)
	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)

	if knife != null and toast != null and toast.get_child_count() > 0:
		if knife_jam.global_position != last_knife_pos:
			var toast_rect = Rect2(toast.global_position - toast.scale * 0.5 * Vector2(toast.texture.get_width(), toast.texture.get_height()),
									toast.scale * Vector2(toast.texture.get_width(), toast.texture.get_height()))
			if toast_rect.has_point(knife_jam.global_position) and knife_jam.modulate.a >= 0.1:
				knife_jam.modulate.a = max(0.0, knife_jam.modulate.a - (globals.game_speed / 1000) * 2 * delta)
				var toast_child = toast.get_child(0)
				toast_child.modulate.a = min(1.0, toast_child.modulate.a + (globals.game_speed / 1000) * delta)

	last_knife_pos = knife_jam.global_position

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
		attach_hand_to_knife(hand_left, true)
	elif dragging_right and attached_right == null:
		attach_hand_to_knife(hand_right, false)

func attach_hand_to_knife(hand: Node2D, is_left: bool) -> void:
	if knife == null or knife.texture == null or not knife.visible:
		return

	var local_pos = knife.to_local(hand.global_position)
	var size = knife.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		knife.rotation_degrees = -140
		if is_left:
			attached_left = knife
		else:
			attached_right = knife
			knife.flip_h = true
			knife.get_child(0).flip_h = true
			knife.rotation_degrees = 140
		hand.texture = globals.closehand_texture

func detach_hand(hand: Node2D, is_left: bool) -> void:
	if is_left:
		attached_left = null
	else:
		attached_right = null
	if hand != null and hand.is_inside_tree():
		hand.texture = globals.openhand_texture
	
	knife.flip_h = false
	knife.get_child(0).flip_h = false
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(knife, "global_position", knife_original_transform[0], 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween2.tween_property(knife, "rotation_degrees", knife_original_transform[1], 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween2.tween_callback(Callable(self, "_on_knife_reset_done"))

func _on_knife_reset_done():
	knife.get_child(0).modulate.a = 1

func _input(event):
	super._input(event)
