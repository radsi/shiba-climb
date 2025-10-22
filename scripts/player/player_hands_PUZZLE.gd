extends HANDS

@onready var puzzle_manager = $"../Puzzle"
@onready var pieces_pos = $"../pieces_pos"

var attached_left: Sprite2D = null
var attached_right: Sprite2D = null
var locked_pieces := {}
var last_attached: Sprite2D = null

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	
	if all_pieces_locked():
		locked_pieces.clear()
		globals.minigame_completed = true
		if globals.is_single_minigame:
			globals.is_playing_minigame_anim = true
			await get_tree().create_timer(1).timeout
			globals.is_playing_minigame_anim = false
			globals.time_left = globals.game_time
			puzzle_manager.restart()
	
	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)

func update_attached_hand(attached, hand: Node2D, is_left: bool, delta: float) -> void:
	if hand == null or hand.visible == false or not hand.is_inside_tree():
		return

	var is_dragging = dragging_left if is_left else dragging_right

	# Soltar pieza si no se está arrastrando
	if attached != null and not is_dragging:
		detach_hand(hand, is_left)
		return

	# Mover pieza agarrada junto con la mano
	if attached != null and attached.is_inside_tree():
		attached.global_position = Vector2(hand.global_position.x - [30,-30][int(is_left)], hand.global_position.y - 30)
		hand.texture = globals.closehand_texture
	else:
		hand.texture = globals.openhand_texture

	# Agarrar nueva pieza si no hay ninguna
	if attached == null and is_dragging:
		attach_hand_to_piece(hand, is_left)

func attach_hand_to_piece(hand: Node2D, is_left: bool) -> void:
	var closest_piece: Sprite2D = null
	var closest_dist = INF

	for piece in puzzle_manager.pieces:
		if piece == null or piece.texture == null or not piece.visible:
			continue
		if piece in locked_pieces and locked_pieces[piece]:
			continue

		var dist = hand.global_position.distance_to(piece.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_piece = piece

	if closest_piece != null and closest_dist < 100:
		last_attached = closest_piece
		if is_left:
			attached_left = closest_piece
		else:
			attached_right = closest_piece

func detach_hand(hand: Node2D, is_left: bool) -> void:
	var piece: Sprite2D = attached_left if is_left else attached_right
	if is_left:
		attached_left = null
	else:
		attached_right = null

	if piece == null:
		return

	var snap_radius = 80
	var closest_node: Node2D = null
	var closest_dist = INF

	for pos_node in pieces_pos.get_children():
		var dist = piece.global_position.distance_to(pos_node.global_position)
		if dist < snap_radius and dist < closest_dist:
			closest_dist = dist
			closest_node = pos_node

	if closest_node != null and piece.target_node == pieces_pos.get_children().find(closest_node):
		piece.global_position = closest_node.global_position
		locked_pieces[piece] = true
	else:
		locked_pieces[piece] = false

	hand.texture = globals.openhand_texture

func all_pieces_locked() -> bool:
	if puzzle_manager.pieces.size() < 1: 
		return false
	for piece in puzzle_manager.pieces:
		if not is_instance_valid(piece):
			continue
		if piece not in locked_pieces or not locked_pieces[piece]:
			return false
	return true
	
func _input(event):
	super._input(event)
