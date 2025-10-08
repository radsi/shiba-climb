extends HANDS

@onready var racket: Sprite2D = $"../Racket2"

var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

@onready var racket_character = $"../Racket2/Racket"
@onready var impact = $"../impact"

func _ready() -> void:
	super._ready()
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _input(event: InputEvent) -> void:
	super._input(event)

func _process(delta: float) -> void:
	super._process(delta)

	update_attached_hand(attached_left, hand_left, true, last_pos_left)
	update_attached_hand(attached_right, hand_right, false, last_pos_right)

	if dragging_left:
		last_pos_left = hand_left.global_position
	if dragging_right:
		last_pos_right = hand_right.global_position

func update_attached_hand(attached, hand: Node2D, is_left: bool, prev_pos: Vector2) -> void:
	if hand == null or not hand.is_inside_tree():
		return

	if dragging_left and attached_left == null and is_left:
		attach_hand_to_racket(hand_left, true)
	elif dragging_right and attached_right == null and not is_left:
		attach_hand_to_racket(hand_right, false)

	if not dragging_left and attached_left != null and is_left:
		detach_hand(hand_left, true)
	if not dragging_right and attached_right != null and not is_left:
		detach_hand(hand_right, false)

	if attached != null and attached.is_inside_tree():
		attached.global_position = Vector2(
			hand.global_position.x - [30, -30][int(is_left)],
			hand.global_position.y - 30
		)
		hand.texture = globals.closehand_texture

		var dy = hand.global_position.y - prev_pos.y
		if abs(dy) > 10.0:
			racket_character.rotation_degrees = clamp(racket_character.rotation_degrees + sign(dy) * 2, -30, 30)
	else:
		hand.texture = globals.openhand_texture

func attach_hand_to_racket(hand: Node2D, is_left: bool) -> void:
	var local_pos = racket.to_local(hand.global_position)
	var size = racket.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		if is_left:
			attached_left = racket
			racket.rotation_degrees = 10
		else:
			attached_right = racket
			racket.rotation_degrees = -10
		hand.texture = globals.closehand_texture

func detach_hand(hand: Node2D, is_left: bool) -> void:
	if is_left:
		attached_left = null
	else:
		attached_right = null
	if hand != null and hand.is_inside_tree():
		hand.texture = globals.openhand_texture

func _on_area_2d_body_entered(body: Node2D) -> void:
	impact.play()
