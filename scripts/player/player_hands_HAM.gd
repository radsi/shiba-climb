extends HANDS

@onready var knife: Sprite2D = $"../HamKnife"
@onready var ham_top: Sprite2D = $"../HamTop"
@onready var ham: Sprite2D = $"../Ham"
@onready var cut: AudioStreamPlayer2D = $"../cut"
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

var original_top_pos
var last_knife_pos: Vector2

var rotation_timer = 0.0
var restart_timer = 0.0

func _ready():
	super._ready()
	last_knife_pos = knife.global_position
	original_top_pos = ham_top.global_position

func _process(delta):
	super._process(delta)

	if globals.minigame_completed == true:
		cut.stop()
		rotation_timer += delta
		restart_timer += delta

		if rotation_timer >= 0.5:
			ham_top.rotation_degrees *= -1
			rotation_timer = 0.0

		if globals.is_single_minigame == true and restart_timer >= 3.0:
			restart_minigame()
		return

	var knife_pos = knife.global_position

	if knife_pos.x >= 689 and globals.minigame_completed == false:
		globals.minigame_completed = true
		rotation_timer = 0.0
		restart_timer = 0.0
		ham_top.global_position = Vector2(418.0, 347.0)
		ham_top.rotation_degrees = 10
		return

	knife_pos.y = clamp(knife_pos.y, 463.0, 610.0)

	if (attached_left != null or attached_right != null):
		var dy = knife_pos.y - last_knife_pos.y
		if dy != 0:
			if cut.playing == false:
				cut.play()
			knife_pos.x += 1.5

	knife.global_position = knife_pos
	last_knife_pos = knife_pos

	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)


func update_attached_hand(attached, hand: Node2D, is_left: bool, delta: float) -> void:
	if not dragging_left and attached_left != null:
		detach_hand(hand_left, true)
	if not dragging_right and attached_right != null:
		detach_hand(hand_right, false)

	if hand == null or hand.visible == false or not hand.is_inside_tree():
		return

	if attached != null:
		if attached.is_inside_tree():
			attached.global_position = Vector2(attached.global_position.x, hand.global_position.y - 80)
			hand.texture = globals.closehand_texture
		else:
			detach_hand(hand, is_left)

	if dragging_left and attached_left == null:
		attach_hand_to_knife(hand_left, true)
	elif dragging_right and attached_right == null:
		attach_hand_to_knife(hand_right, false)
	
func restart_minigame():
	globals.minigame_completed = false
	rotation_timer = 0.0
	restart_timer = 0.0
	knife.global_position = Vector2(500.0, 463.0)
	ham_top.global_position = original_top_pos
	ham_top.rotation_degrees = 0.0

func attach_hand_to_knife(hand: Node2D, is_left: bool) -> void:
	if knife == null or knife.texture == null or not knife.visible:
		return

	var local_pos = knife.to_local(hand.global_position)
	var size = knife.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		if is_left:
			attached_left = knife
		else:
			attached_right = knife
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
