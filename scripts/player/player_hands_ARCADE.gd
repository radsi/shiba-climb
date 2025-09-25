extends HANDS

@onready var button = $"../button/buttonHead"
@onready var joystick = $"../joystick/JoystickHead"

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	
	if (_is_over_object(hand_left.global_position, button) and dragging_left) or (_is_over_object(hand_right.global_position, button) and dragging_right):
		_press_arcade_button()
	else:
		_release_arcade_button()
	
	if (_is_over_object(hand_left.global_position, joystick) and dragging_left) or (_is_over_object(hand_right.global_position, joystick) and dragging_right):
		if (hand_left.global_position.x < joystick.global_position.x and dragging_left) or (hand_right.global_position.x < joystick.global_position.x and dragging_right):
			joystick.rotation = 100
		else:
			joystick.rotation = -100
	
	if not dragging_left and not dragging_right:
		joystick.rotation = 0

func _is_over_object(pos: Vector2, object: Node2D) -> bool:
	var size = object.texture.get_size() * object.scale
	var rect = Rect2(object.global_position - size * 0.5, size)
	return rect.has_point(pos)
	

func _press_arcade_button():
	button.position.y = 12

func _release_arcade_button():
	button.position.y = 6
