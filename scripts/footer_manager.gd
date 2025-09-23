extends Node

func _process(delta: float) -> void:
	$".".get_child(2).text = str(globals.life)
