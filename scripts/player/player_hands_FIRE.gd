extends HANDS

@onready var fire_sprites = [preload("res://mini games sprites/fire/fire1.png"), preload("res://mini games sprites/fire/fire2.png"), preload("res://mini games sprites/fire/fire3.png")]

@onready var fan: Sprite2D = $"../Fan"
@onready var fire: Sprite2D = $"../bonfire/fire"
var attached_left: Sprite2D = null
var attached_right: Sprite2D = null

var last_fan_pos: Vector2

var timer = 0

func _ready():
	super._ready()
	last_fan_pos = fan.global_position

func _process(delta):
	super._process(delta)
	
	timer += delta
	
	if timer >= 0.5:
		fire.texture = fire_sprites[0]
	if timer >= 1:
		fire.texture = fire_sprites[1]
	if timer >= 1.5:
		fire.texture = fire_sprites[2]
		timer = 0
	
	update_attached_hand(attached_left, hand_left, true, delta)
	update_attached_hand(attached_right, hand_right, false, delta)

	if last_fan_pos.y != fan.global_position.y:
		if (fire.scale.x >= 0.6 or fire.scale.x <= 0): return
		fire.scale.x += (globals.game_speed / 100000) + 0.0015
		fire.scale.y += (globals.game_speed / 100000) + 0.0015

	last_fan_pos = fan.global_position
	
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
		attach_hand_to_fan(hand_left, true)
	elif dragging_right and attached_right == null:
		attach_hand_to_fan(hand_right, false)

func attach_hand_to_fan(hand: Node2D, is_left: bool) -> void:
	var local_pos = fan.to_local(hand.global_position)
	var size = fan.texture.get_size()
	var rect = Rect2(-size * 0.5, size)
	if rect.has_point(local_pos):
		fan.rotation_degrees = 45
		if is_left:
			attached_left = fan
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
