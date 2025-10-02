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
			hand.texture = globals.closehand_texture
		
			if attached.visible == false:
				if attached == attached_left:
					attached_left = null
				else:
					attached_right = null
		else:
			if attached == attached_left:
				attached_left = null
			else:
				attached_right = null
			if hand != null and hand.is_inside_tree():
				hand.texture = globals.openhand_texture
	
	if dragging_left and attached_left == null:
		attach_hand_to_apple(hand_left, true)
	elif dragging_right and attached_right == null:
		attach_hand_to_apple(hand_right, false)

func attach_hand_to_apple(hand: Node2D, is_left: bool) -> void:
	var apple = get_apple_under_hand(hand)
	if apple != null and apple.visible == true:
		if is_left:
			attached_left = apple
		else:
			attached_right = apple
		hand.texture = globals.closehand_texture
		$"../AudioStreamPlayer2D".play()

func _input(event):
	super._input(event)

func get_apple_under_hand(hand: Node2D) -> Sprite2D:
	for apple in apples.get_children():
		if apple is Sprite2D and apple.texture != null:
			var local_pos = apple.to_local(hand.global_position)
			var size = apple.texture.get_size()
			var rect = Rect2(-size * 0.5, size)
			if rect.has_point(local_pos):
				return apple
	return null
