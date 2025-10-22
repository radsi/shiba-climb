extends HANDS

@onready var button = $"../button/buttonHead"
@onready var joystick = $"../joystick/JoystickHead"
@onready var ship = $"../game/playerShip"
@onready var screen = $"../screen"
@onready var bullet = preload("res://prefabs/arcade/player_bullet.tscn")

var bullet_interval = 0.25
var bullet_timer = 1

var button_is_pressed = false

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	
	if (_is_over_object(hand_left.global_position, button) and dragging_left and hand_left.visible == true) or (_is_over_object(hand_right.global_position, button) and dragging_right and hand_right.visible == true):
		_press_arcade_button(delta)
	else:
		_release_arcade_button()
	
	if (_is_over_object(hand_left.global_position, joystick) and dragging_left) or (_is_over_object(hand_right.global_position, joystick) and dragging_right):
		if button_is_pressed: return
		if (hand_left.global_position.x < joystick.global_position.x and dragging_left) or (hand_right.global_position.x < joystick.global_position.x and dragging_right):
			joystick.rotation = 100
		else:
			joystick.rotation = -100
	
	if (not dragging_left and not dragging_right) or button_is_pressed == true:
		joystick.rotation = 0
	
	_move_ship(delta)

func _move_ship(delta):
	ship.global_position.x += -joystick.rotation * (globals.game_speed / 100) * delta
	ship.global_position.x = clamp(ship.global_position.x, 214, 880)

func _is_over_object(pos: Vector2, object: Node2D) -> bool:
	var size = object.texture.get_size() * object.scale
	var rect = Rect2(object.global_position - size * 0.5, size)
	return rect.has_point(pos)

func _press_arcade_button(delta):
	button_is_pressed = true
	button.position.y = 12
	bullet_timer += delta
	
	if bullet_timer >= bullet_interval:
		bullet_timer = 0
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = Vector2(ship.global_position.x, ship.global_position.y - 35)
		$"../bullets".add_child(new_bullet)

func _release_arcade_button():
	button_is_pressed = false
	button.position.y = 6
	bullet_timer = 1
