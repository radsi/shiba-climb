extends Node2D

@onready var enemies = $enemies
@onready var bullets = $bullets

var frame_interval = 0.5
var current_frame = 7
var timer = 0

var active_enemies = []

func _ready() -> void:
	var children = enemies.get_children()
	children.shuffle()
	
	for i in range(min(62, children.size())):
		var child = children[i]
		if child is Node2D or child is Control:
			child.hide()
	
	for e in enemies.get_children():
		if e.visible == true:
			active_enemies.append(e)

func _process(delta: float) -> void:
	if active_enemies.size() <= 0:
		globals.minigame_completed = true
		return
	
	timer += delta
	if timer < frame_interval:
		return
	
	timer = 0
	
	if current_frame == 7:
		current_frame = 8 
	else:
		current_frame = 7
	
	for enemy: Sprite2D in active_enemies:
		if enemy.visible:
			enemy.frame = current_frame

func _kill_enemy(enemy: Sprite2D):
	active_enemies.erase(enemy)
	enemy.frame = 23
	await get_tree().create_timer(.3).timeout
	enemy.frame = 30
	enemy.hide()

func _enemy_is_dead(enemy: Sprite2D):
	return not active_enemies.has(enemy)
