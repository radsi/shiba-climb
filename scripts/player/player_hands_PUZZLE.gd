extends HANDS

@onready var puzzle_manager = $"../Puzzle"
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	
	if puzzle_manager.pieces.size() < 3: return
	
	for piece in puzzle_manager.pieces:
		print(piece.name)
	
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
			hand.texture = globals.closehand_texture
		else:
			detach_hand(hand, is_left)

	if dragging_left and attached_left == null:
		for piece in puzzle_manager.pieces:
			attach_hand_to_piece(piece, hand_left, true)
	elif dragging_right and attached_right == null:
		for piece in puzzle_manager.pieces:
			attach_hand_to_piece(piece, hand_right, true)

func attach_hand_to_piece(piece: Sprite2D, hand: Node2D, is_left: bool) -> void:
	var local_pos = piece.to_local(hand.global_position)
	var size = piece.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		if is_left:
			attached_left = piece
		else:
			attached_right = piece
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
