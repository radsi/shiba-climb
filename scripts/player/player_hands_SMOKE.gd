extends HANDS

@onready var _match = $"../Matches/Match"
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

func _ready() -> void:
	super._ready()

func _process(delta):
	super._process(delta)

	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)

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
		else:
			detach_hand(hand, is_left)

	if dragging_left and attached_left == null:
		attach_hand_to_match(hand_left, true)
	elif dragging_right and attached_right == null:
		attach_hand_to_match(hand_right, false)

func detach_hand(hand: Node2D, is_left: bool) -> void:
	if is_left:
		attached_left = null
	else:
		attached_right = null

	hand.texture = globals.openhand_texture

func attach_hand_to_match(hand: Node2D, is_left: bool) -> void:
	if _match == null:
		return
		
	var local_pos = _match.to_local(hand.global_position)
	var size = _match.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		_match.z_index = 0
		_match.rotation_degrees = -50
		if is_left:
			attached_left = _match
		else:
			attached_right = _match
			_match.rotation_degrees = -140
