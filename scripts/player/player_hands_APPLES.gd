extends HANDS

@onready var apples = $"../Apples"
var attached_left : Sprite2D = null
var attached_right : Sprite2D = null
var grab_margin = 20.0

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)

	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)

func update_attached_hand(attached, hand: Node2D, is_left: bool, delta: float) -> void:
	if hand == null or not hand.is_inside_tree():
		return

	if attached != null:
		if attached.is_inside_tree():
			attached.global_position = hand.global_position
			if is_left:
				durability_left -= globals.hands_drain_rate * delta
				durability_left = clamp(durability_left, 0, globals.hands_max_durability)
				hand.modulate = Color(1, durability_left/globals.hands_max_durability, durability_left/globals.hands_max_durability)
			else:
				durability_right -= globals.hands_drain_rate * delta
				durability_right = clamp(durability_right, 0, globals.hands_max_durability)
				hand.modulate = Color(1, durability_right/globals.hands_max_durability, durability_right/globals.hands_max_durability)
			hand.texture = globals.closehand_texture
		else:
			if attached == attached_left:
				attached_left = null
			else:
				attached_right = null
			if hand != null and hand.is_inside_tree():
				hand.texture = globals.openhand_texture

func attach_hand_to_apple(hand: Node2D, is_left: bool) -> void:
	var apple = get_apple_under_hand(hand)
	if apple != null:
		if is_left:
			attached_left = apple
		else:
			attached_right = apple
		hand.texture = globals.closehand_texture

func _input(event):
	super._input(event)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and hand_left != null:
			if event.pressed and attached_left == null:
				attach_hand_to_apple(hand_left, true)
		if event.button_index == MOUSE_BUTTON_RIGHT and hand_right != null:
			if event.pressed and attached_right == null:
				attach_hand_to_apple(hand_right, false)

func get_apple_under_hand(hand: Node2D) -> Sprite2D:
	for apple in apples.get_children():
		if apple is Sprite2D and apple.texture != null:
			var local_pos = apple.to_local(hand.global_position)
			var size = apple.texture.get_size()
			var rect = Rect2(-size * 0.5, size)
			if rect.has_point(local_pos):
				return apple
	return null
