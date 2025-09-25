extends HANDS

@onready var dirty_objects = $"../Dirty"

var transparency_step = 0.05

func _ready():
	grappling = true
	super._ready()

func _input(event):
	super._input(event)

func _process(delta):
	increase_transparency_under_hand(hand_left)
	increase_transparency_under_hand(hand_right)
	super._process(delta)

func increase_transparency_under_hand(hand: Node2D):
	if hand == null:
		return

	for obj in dirty_objects.get_children():
		if obj is Sprite2D and obj.texture != null:
			var local_pos = obj.to_local(hand.global_position)
			var tex_size = obj.texture.get_size()
			var rect = Rect2(-tex_size * 0.5, tex_size)
			if rect.has_point(local_pos):
				var c = obj.modulate
				c.a = clamp(c.a - transparency_step, 0, 1)
				obj.modulate = c
