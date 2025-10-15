extends Node

var posible_kanjis = ["う", "ロ", "ミ", "二", "ウ", "ア", "ド", "人", "ら", "ん", "ム", "⭐"]

func _ready() -> void:
	globals.is_playing_minigame_anim = true
	$SubViewportContainer/SubViewport/Label.text = posible_kanjis[randf_range(0, posible_kanjis.size() - 1)]
