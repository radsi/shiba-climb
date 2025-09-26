extends Sprite2D

@onready var arcade_script = get_parent().get_parent()

func _ready() -> void:
	await get_tree().create_timer(2.25).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position.y -= globals.game_speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if arcade_script._enemy_is_dead(enemy): return
	arcade_script._kill_enemy(enemy)
