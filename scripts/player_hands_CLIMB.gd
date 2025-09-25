class_name HANDS_climb
extends HANDS

@onready var grabables = $"../Grabables"

var returning_left = false
var returning_right = false
var attached_left : Sprite2D = null
var attached_right : Sprite2D = null
var last_attached_left : Sprite2D = null
var last_attached_right : Sprite2D = null

var return_time = 0.2
var grab_margin = 20.0

func _ready() -> void:
	grappling = true
	super._ready()
	attached_left = $"../Grabables/StarterBrick"
	last_attached_left = attached_left
	attached_right = $"../Grabables/StarterBrick"
	last_attached_right = attached_right

func _input(event):
	if not (event is InputEventMouseButton):
		super._input(event)
		return
	if event.pressed:
		super._input(event)
		return
	var was_dragging_left = dragging_left
	var was_dragging_right = dragging_right
	super._input(event)
	if was_dragging_left:
		var g = get_grabable_under_hand(hand_left)
		if g != null:
			attach_hand(true, g)
		else:
			return_hand(true)
	if was_dragging_right:
		var g2 = get_grabable_under_hand(hand_right)
		if g2 != null:
			attach_hand(false, g2)
		else:
			return_hand(false)

func _process(delta):
	super._process(delta)
	var viewport_height = get_viewport().get_visible_rect().size.y
	process_hand_climb(true, delta, viewport_height)
	process_hand_climb(false, delta, viewport_height)

func process_hand_climb(is_left: bool, delta: float, viewport_height: float):
	var hand = hand_left if is_left else hand_right
	if hand == null:
		return
	var hand_screen_pos = get_viewport().get_canvas_transform() * hand.global_position
	var attached = attached_left if is_left else attached_right
	var returning = returning_left if is_left else returning_right
	if not (is_left and dragging_left) and not (not is_left and dragging_right):
		if attached != null:
			if not attached.is_inside_tree():
				if is_left:
					attached_left = null
				else:
					attached_right = null
			elif not returning:
				hand.global_position.y = attached.global_position.y
	var durability = durability_left if is_left else durability_right
	if hand_screen_pos.y > viewport_height or durability <= 0:
		globals.life -= 1
		globals.has_lost_life = true
		globals._start_roll()
		if is_left:
			hand_left.queue_free()
			hand_left = null
			attached_left = null
			last_attached_left = null
			dragging_left = false
			returning_left = false
		else:
			hand_right.queue_free()
			hand_right = null
			attached_right = null
			last_attached_right = null
			dragging_right = false
			returning_right = false

func attach_hand(is_left: bool, grabbed: Sprite2D):
	var hand = hand_left if is_left else hand_right
	if hand == null:
		return
	if grabbed != null:
		if is_left:
			attached_left = grabbed
			last_attached_left = grabbed
			hand_left.global_position.y = grabbed.global_position.y
			hand_left.texture = globals.closehand_texture
		else:
			attached_right = grabbed
			last_attached_right = grabbed
			hand_right.global_position.y = grabbed.global_position.y
			hand_right.texture = globals.closehand_texture

func return_hand(is_left: bool):
	var hand = hand_left if is_left else hand_right
	if hand == null:
		return
	var last_attached = last_attached_left if is_left else last_attached_right
	if last_attached == null or not last_attached.is_inside_tree():
		return
	var target_y = last_attached.global_position.y - 10 + globals.game_speed * return_time
	var target = Vector2(last_attached.global_position.x, target_y)
	if is_left:
		returning_left = true
	else:
		returning_right = true
	var tween = create_tween()
	tween.tween_property(hand, "global_position", target, return_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		if is_left:
			returning_left = false
			if last_attached_left != null and last_attached_left.is_inside_tree():
				attached_left = last_attached_left
			if hand_left != null:
				hand_left.texture = globals.closehand_texture
		else:
			returning_right = false
			if last_attached_right != null and last_attached_right.is_inside_tree():
				attached_right = last_attached_right
			if hand_right != null:
				hand_right.texture = globals.closehand_texture
	)

func get_grabable_under_hand(hand: Node2D) -> Sprite2D:
	if hand == null:
		return null
	for g in grabables.get_children():
		if g is Sprite2D and g.texture != null:
			var size = g.texture.get_size() * g.get_global_scale()
			var rect = Rect2(g.global_position - size * 0.5, size)
			if rect.has_point(hand.global_position):
				return g
			var max_half = max(size.x, size.y) * 0.5
			if hand.global_position.distance_to(g.global_position) <= max_half + grab_margin:
				return g
	return null
