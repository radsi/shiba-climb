extends Node

@onready var toast_jam = $Toast/ToastJam
@onready var toast = $Toast
var timer = 0.0
var bite_count = 0
var burp_played = false
const BURP_WAIT := 0.8

func _process(delta: float) -> void:
	if toast_jam == null:
		return

	if toast_jam.modulate.a >= 0.75:
		globals.minigame_completed = true
		if globals.is_single_minigame:
			toast_jam.modulate.a = 1
			return
		if burp_played:
			return

		timer += delta
		if timer < 0.5:
			return
		timer = 0.0

		toast_jam.visible = false
		bite_count += 1

		if bite_count >= 6:
			$burp.play()
			burp_played = true
			await get_tree().create_timer(BURP_WAIT).timeout
			if is_instance_valid(toast):
				toast.queue_free()
			return
		else:
			$bite.play()

		if bite_count == 5:
			toast.texture = load("res://mini games sprites/toasts/bite"+str(bite_count)+".png")
			return

		toast.texture = load("res://mini games sprites/toasts/bite"+str(bite_count)+".png")
