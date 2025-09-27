extends Node2D

@onready var enemies = $enemies
@onready var bullets = $bullets

var frame_interval = 0.5
var current_frame = 7
var timer = 0.0

var active_enemies: Array = []

func _ready() -> void:
	_set_enemies()

func _process(delta: float) -> void:
	if active_enemies.size() <= 0:
		if globals.is_single_minigame:
			_set_enemies()
		globals.minigame_completed = true
		return
	
	timer += delta
	if timer < frame_interval:
		return
	timer = 0.0

	current_frame = 8 if current_frame == 7 else 7

	for enemy: Sprite2D in active_enemies:
		if enemy.visible:
			enemy.frame = current_frame

func _kill_enemy(enemy: Sprite2D) -> void:
	active_enemies.erase(enemy)
	enemy.frame = 23
	await get_tree().create_timer(0.3).timeout
	enemy.frame = 30
	enemy.hide()

func _enemy_is_dead(enemy: Sprite2D) -> bool:
	return not active_enemies.has(enemy)

func _set_enemies() -> void:
	var children = enemies.get_children()
	children.shuffle()

	active_enemies.clear()
	
	for i in range(children.size()):
		var child = children[i]
		if child is Node2D or child is Control:
			child.visible = true
			if i < 62:
				child.hide()
			else:
				active_enemies.append(child)
