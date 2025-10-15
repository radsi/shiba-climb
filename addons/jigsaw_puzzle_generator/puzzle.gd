extends Node2D
class_name Puzzle

@export var puzzle:Texture2D
@export var number_of_pieces:int = 4
@export var piece_margin: float = 0.13
var piece_size: int

var pieces: Array[Piece]
var groups: Array[Array]

var inset:Texture2D = load("res://addons/jigsaw_puzzle_generator/inset.png")
var outset:Texture2D = load("res://addons/jigsaw_puzzle_generator/outset.png")
var straight:Texture2D = load("res://addons/jigsaw_puzzle_generator/straight.png")
var masks:Dictionary

var dragging := false
var dragged_piece:Piece = null
var dragged_offset := Vector2.ZERO
var match_whole_piece := false

var puzzle_pictures = [preload("res://mini games sprites/puzzles/monalisa.png"), preload("res://mini games sprites/puzzles/hackclub.png"), preload("res://mini games sprites/puzzles/toilet.png")]

func restart():
	randomize()
	puzzle = puzzle_pictures[randi() % puzzle_pictures.size() - 1]
	for piece in pieces:
		piece.queue_free()
	
	_ready()

func _ready():
	randomize()
	puzzle = puzzle_pictures[randi() % puzzle_pictures.size() - 1]
	
	piece_size = calculate_piece_size()
	var margin = piece_size * piece_margin
	var x_num = int(puzzle.get_width()/piece_size)
	var y_num = int(puzzle.get_height()/piece_size)
	
	masks = {}
	for tops in Piece.STYLE.values():
		masks[tops] = {}
		for rights in Piece.STYLE.values():
			masks[tops][rights] = {}
			for bottoms in Piece.STYLE.values():
				masks[tops][rights][bottoms] = {}
				for lefts in Piece.STYLE.values():
					masks[tops][rights][bottoms][lefts] = null
	
	generate_masks()
	
	var p = load("res://addons/jigsaw_puzzle_generator/piece.tscn")
	for y in y_num:
		for x in x_num:
			var rect = Rect2(x*piece_size-margin, y*piece_size-margin, piece_size+(2*margin), piece_size+(2*margin))
			var piece = p.instantiate()
			var sds = generate_sides(x, y, x_num, y_num)
			var group:Array[Piece] = []
			group.append(piece)
			groups.append(group)
			add_neighbors(x, y, x_num, piece)
			piece.group = group
			piece.texture = puzzle
			piece.region_rect = rect
			piece.sides = sds
			piece.mask = masks[sds[Piece.SIDE.TOP]][sds[Piece.SIDE.RIGHT]][sds[Piece.SIDE.BOTTOM]][sds[Piece.SIDE.LEFT]]
			var min = Vector2(130, 130)
			var max = Vector2(942.0, 824.0)

			var random_pos = Vector2(
				randf_range(min.x, max.x),
				randf_range(min.y, max.y)
			)
			piece.position = random_pos
			pieces.append(piece)
			piece.target_node = pieces.size()-1
			add_child(piece)

func calculate_piece_size() -> int:
	var w = puzzle.get_width()
	var h = puzzle.get_height()
	
	var y = sqrt(((h*number_of_pieces)/w))
	
	return int(h/y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == JOY_BUTTON_RIGHT_SHOULDER or event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			if event.pressed:
				dragging = true
			else:
				if dragged_piece != null:
					var neighbor = dragged_piece.next_to_neighbor(match_whole_piece)
					
					if neighbor != null:
						var group_adjust := Vector2.ZERO
						match neighbor:
							dragged_piece.left_neighbor:
								group_adjust = dragged_piece.position - Vector2(dragged_piece.left_neighbor.position.x + piece_size, dragged_piece.left_neighbor.position.y)
							dragged_piece.top_neighbor: 
								group_adjust = dragged_piece.position - Vector2(dragged_piece.top_neighbor.position.x, dragged_piece.top_neighbor.position.y + piece_size)
							dragged_piece.right_neighbor: 
								group_adjust = dragged_piece.position - Vector2(dragged_piece.right_neighbor.position.x - piece_size, dragged_piece.right_neighbor.position.y)
							dragged_piece.bottom_neighbor:
								group_adjust = dragged_piece.position - Vector2(dragged_piece.bottom_neighbor.position.x, dragged_piece.bottom_neighbor.position.y - piece_size)
					
						if neighbor.group != dragged_piece.group:
							for g in dragged_piece.group:
								g.position -= group_adjust
								
							for np in neighbor.group:
								dragged_piece.group.append(np)
								np.group = dragged_piece.group
						
				dragging = false
				dragged_piece = null

func generate_masks():
	for top_style in Piece.STYLE.values():
		for right_style in Piece.STYLE.values():
			for bottom_style in Piece.STYLE.values():
				for left_style in Piece.STYLE.values():
					var s = {
						Piece.SIDE.TOP: top_style,
						Piece.SIDE.RIGHT: right_style,
						Piece.SIDE.BOTTOM: bottom_style,
						Piece.SIDE.LEFT: left_style
					}
					var path = "res://addons/jigsaw_puzzle_generator/mask_cache/" + str(top_style) + "_" + str(right_style) + "_" + str(bottom_style) + "_" + str(left_style) + ".png"
					if ResourceLoader.exists(path):
						masks[top_style][right_style][bottom_style][left_style] = load(path)
					else:
						masks[top_style][right_style][bottom_style][left_style] = build_mask(s)
						var im:Image = masks[top_style][right_style][bottom_style][left_style].get_image()
						im.save_png(path)

func build_mask(sides) -> Texture2D:
	var mask_image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color.BLACK)
	
	var inset_left = inset.get_image()
	inset_left.rotate_90(COUNTERCLOCKWISE)
	
	var inset_bottom = inset.get_image()
	inset_bottom.rotate_180()
	
	var inset_right = inset.get_image()
	inset_right.rotate_90(CLOCKWISE)
	
	var outset_left = outset.get_image()
	outset_left.rotate_90(COUNTERCLOCKWISE)
	
	var outset_bottom = outset.get_image()
	outset_bottom.rotate_180()
	
	var outset_right = outset.get_image()
	outset_right.rotate_90(CLOCKWISE)
	
	var straight_left = straight.get_image()
	straight_left.rotate_90(COUNTERCLOCKWISE)
	
	var straight_bottom = straight.get_image()
	straight_bottom.rotate_180()
	
	var straight_right = straight.get_image()
	straight_right.rotate_90(CLOCKWISE)
	
	masking(sides, Piece.SIDE.TOP, mask_image, inset.get_image(), outset.get_image(), straight.get_image())
	masking(sides, Piece.SIDE.LEFT, mask_image, inset_left, outset_left, straight_left)
	masking(sides, Piece.SIDE.BOTTOM, mask_image, inset_bottom, outset_bottom, straight_bottom)
	masking(sides, Piece.SIDE.RIGHT, mask_image, inset_right, outset_right, straight_right)
	
	return ImageTexture.create_from_image(mask_image) # Convert the image to a Texture2D
			
func masking(sides, side:Piece.SIDE, mask_image:Image, ins:Image, ots:Image, st:Image) -> void:
	match sides[side]:
		Piece.STYLE.STRAIGHT: blending(mask_image, st)
		Piece.STYLE.INSET:    blending(mask_image, ins)
		Piece.STYLE.OUTSET:	blending(mask_image, ots)

func blending(m:Image, other:Image) -> void:
	for y in range(m.get_width()):
		for x in range(m.get_height()):
			var mask_pixel = m.get_pixel(x, y)
			var other_pixel = other.get_pixel(x, y)
			
			if other_pixel.a > 0.5:
				var new_pixel = max(mask_pixel.r, other_pixel.r)
				m.set_pixel(x, y, Color(new_pixel, new_pixel, new_pixel, 1.0))

func generate_sides(x:int, y:int, x_num:int, y_num:int) -> Dictionary:
	var rv = {}
	
	if x == x_num-1:
		rv[Piece.SIDE.RIGHT] = Piece.STYLE.STRAIGHT
	else:
		if randf() > 0.5:
			rv[Piece.SIDE.RIGHT] = Piece.STYLE.INSET
		else:
			rv[Piece.SIDE.RIGHT] = Piece.STYLE.OUTSET
			
	if y == y_num-1:
		rv[Piece.SIDE.BOTTOM] = Piece.STYLE.STRAIGHT
	else:
		if randf() > 0.5:
			rv[Piece.SIDE.BOTTOM] = Piece.STYLE.INSET
		else:
			rv[Piece.SIDE.BOTTOM] = Piece.STYLE.OUTSET
	
	if x > 0:
		rv[Piece.SIDE.LEFT] = opposing_set(pieces.back(), Piece.SIDE.RIGHT)
	else:
		rv[Piece.SIDE.LEFT] = Piece.STYLE.STRAIGHT
		
	if y > 0:
		rv[Piece.SIDE.TOP] = opposing_set(pieces[pieces.size()-x_num], Piece.SIDE.BOTTOM)
	else:
		rv[Piece.SIDE.TOP] = Piece.STYLE.STRAIGHT
	return rv
	
func opposing_set(p:Piece, s:Piece.SIDE) -> Piece.STYLE:
	if p.sides[s] == Piece.STYLE.INSET:
		return Piece.STYLE.OUTSET
	else:
		return Piece.STYLE.INSET

func shuffle(area: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)) -> void:
	if area == null or area.get_area() == 0:
		var screen = Vector2(get_window().size.x, get_window().size.y) / get_canvas_transform().get_scale()
		area = Rect2(Vector2(-screen.x/2, -screen.y/2),screen)
		#area.size = area.size/$Camera2D.zoom
		#area.position = $Camera2D.position - (area.size/2)
		
	for piece:Piece in pieces:
		var x = randi_range(area.position.x, area.position.x + area.size.x - piece_size)
		var y = randi_range(area.position.y, area.position.y + area.size.y - piece_size)
		piece.position.x = x
		piece.position.y = y
	

func add_neighbors(x:int, y:int, x_max:int, piece:Piece) -> void:
	if x > 0:
		var left_piece:Piece = pieces.back()
		left_piece.right_neighbor = piece
		piece.left_neighbor = left_piece
		
	if y > 0:
		var top_piece:Piece = pieces[pieces.size()-x_max]
		top_piece.bottom_neighbor = piece
		piece.top_neighbor = top_piece
