extends HANDS

@onready var fan: Sprite2D = $"../Fan"
@onready var fire: Sprite2D = $"../bonfire/fire"
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

var last_fan_pos: Vector2
var movement_threshold := 5.0
var max_fire_scale := 0.6

func _ready():
	super._ready()
	last_fan_pos = fan.global_position
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

func _process(delta):
	super._process(delta)

	update_attached_hand(attached_left, hand_left, true, last_pos_left)
	update_attached_hand(attached_right, hand_right, false, last_pos_right)

	if dragging_left:
		last_pos_left = hand_left.global_position
	if dragging_right:
		last_pos_right = hand_right.global_position

	last_fan_pos = fan.global_position

func update_attached_hand(attached, hand: Node2D, is_left: bool, prev_pos: Vector2) -> void:
	if hand == null or hand.visible == false or not hand.is_inside_tree():
		return

	if dragging_left and attached_left == null and is_left:
		attach_hand_to_fan(hand_left, true)
	elif dragging_right and attached_right == null and not is_left:
		attach_hand_to_fan(hand_right, false)

	if not dragging_left and attached_left != null and is_left:
		detach_hand(hand_left, true)
	if not dragging_right and attached_right != null and not is_left:
		detach_hand(hand_right, false)

	if attached != null and attached.is_inside_tree():
		attached.global_position = Vector2(hand.global_position.x - [30, -30][int(is_left)], hand.global_position.y - 30)
		hand.texture = globals.closehand_texture

		var dy = hand.global_position.y - prev_pos.y
		if abs(dy) > movement_threshold and globals.is_playing_minigame_anim == false:
			if fire.scale.x < max_fire_scale and fire.scale.x > 0:
				var grow = (globals.game_speed / 100000.0) + 0.003
				fire.scale += Vector2(grow, grow)
	else:
		hand.texture = globals.openhand_texture

func attach_hand_to_fan(hand: Node2D, is_left: bool) -> void:
	var local_pos = fan.to_local(hand.global_position)
	var size = fan.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		if is_left:
			attached_left = fan
			fan.rotation_degrees = 45
		else:
			attached_right = fan
			fan.rotation_degrees = -45
		hand.texture = globals.closehand_texture

func detach_hand(hand: Node2D, is_left: bool) -> void:
	if is_left:
		attached_left = null
	else:
		attached_right = null
	if hand != null and hand.is_inside_tree():
		hand.texture = globals.openhand_texture

func _input(event):
	super._input(event)
