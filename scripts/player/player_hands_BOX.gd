extends HANDS

@onready var jail = $"../jail"
@onready var knock = $"../knock"
@onready var _break = $"../break"

var wall_hitted_left: Node2D = null
var wall_hitted_right: Node2D = null

var left_limit = 327
var right_limit = 751
var top_limit = 236
var bottom_limit = 727

var weak_wall
var wall_hp = 6

var original_hand_pos = {}

func _ready() -> void:
	super._ready()
	weak_wall = jail.get_child(randi_range(0, jail.get_child_count() - 2))
	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position
	
	original_hand_pos[0] = last_pos_left
	original_hand_pos[1] = last_pos_right

func _process(delta: float) -> void:
	super._process(delta)

	var move_left = hand_left.global_position - last_pos_left
	var move_right = hand_right.global_position - last_pos_right

	if wall_hitted_left and dragging_left:
		match wall_hitted_left.name:
			"Line":
				if move_left.x < 0:
					hand_left.global_position = last_pos_left
					if wall_hitted_left == weak_wall:
						_shake_jail(Vector2.LEFT)
			"Line2":
				if move_left.x > 0:
					hand_left.global_position = last_pos_left
					if wall_hitted_left == weak_wall:
						_shake_jail(Vector2.RIGHT)
			"Line3":
				if move_left.y < 0:
					hand_left.global_position = last_pos_left
					if wall_hitted_left == weak_wall:
						_shake_jail(Vector2.UP)
			"Line4":
				if move_left.y > 0:
					hand_left.global_position = last_pos_left
					if wall_hitted_left == weak_wall:
						_shake_jail(Vector2.DOWN)

	if wall_hitted_right and dragging_right:
		match wall_hitted_right.name:
			"Line":
				if move_right.x < 0:
					hand_right.global_position = last_pos_right
					if wall_hitted_right == weak_wall:
						_shake_jail(Vector2.LEFT)
			"Line2":
				if move_right.x > 0:
					hand_right.global_position = last_pos_right
					if wall_hitted_right == weak_wall:
						_shake_jail(Vector2.RIGHT)
			"Line3":
				if move_right.y < 0:
					hand_right.global_position = last_pos_right
					if wall_hitted_right == weak_wall:
						_shake_jail(Vector2.UP)
			"Line4":
				if move_right.y > 0:
					hand_right.global_position = last_pos_right
					if wall_hitted_right == weak_wall:
						_shake_jail(Vector2.DOWN)

	
	if globals.minigame_completed:
		if hand_right.has_node("Area2D_right"):
			hand_right.get_child(0).queue_free()
		if hand_left.has_node("Area2D"):
			hand_left.get_child(0).queue_free()
		
		if globals.is_single_minigame:
			await get_tree().create_timer(0.5).timeout
			globals.minigame_completed = false
			hand_left.global_position = original_hand_pos[0]
			hand_right.global_position = original_hand_pos[1]
			weak_wall.show()
			weak_wall = jail.get_child(randi_range(0, jail.get_child_count() - 1))
		
		return
	
	hand_left.global_position.x = clamp(hand_left.global_position.x, left_limit, right_limit)
	hand_left.global_position.y = clamp(hand_left.global_position.y, top_limit, bottom_limit)

	hand_right.global_position.x = clamp(hand_right.global_position.x, left_limit, right_limit)
	hand_right.global_position.y = clamp(hand_right.global_position.y, top_limit, bottom_limit)

	last_pos_left = hand_left.global_position
	last_pos_right = hand_right.global_position

var _shaking := false

func _shake_jail(direction: Vector2) -> void:
	if _shaking:
		return
	_shaking = true
	var base_pos = jail.position
	var offset = direction.normalized() * 8.0
	var tween = get_tree().create_tween()
	tween.tween_property(jail, "position", base_pos + offset, 0.05)
	tween.tween_property(jail, "position", base_pos, 0.10)
	await get_tree().create_timer(0.16).timeout
	_shaking = false


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == null: return
	if weak_wall == body.get_parent() and dragging_left:
		knock.play()
		wall_hp -= 1
		if wall_hp <= 0:
			weak_wall.hide()
			_break.play()
			globals.minigame_completed = true
	wall_hitted_left = body.get_parent()

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == null: return
	if wall_hitted_left == body.get_parent():
		wall_hitted_left = null

func _on_area_2d_right_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == null: return
	if weak_wall == body.get_parent() and dragging_right:
		knock.play()
		wall_hp -= 1
		if wall_hp <= 0:
			weak_wall.hide()
			_break.play()
			globals.minigame_completed = true
	wall_hitted_right = body.get_parent()

func _on_area_2d_right_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == null: return
	if wall_hitted_right == body.get_parent():
		wall_hitted_right = null
