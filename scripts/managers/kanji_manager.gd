extends Node

var posible_kanjis = ["う", "ロ", "ミ", "ウ", "ア", "ド"]

func _ready() -> void:
	$SubViewportContainer/SubViewport/Label.text = posible_kanjis[randf_range(0, posible_kanjis.size() - 1)]
