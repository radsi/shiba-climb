extends RichTextLabel

func _set_pos(pos: int) -> void:
	if pos == 0:
		text = text.replace("{pos}.", "[img]res://crown icon.png[/img]")
	else:
		text = text.replace("{pos}", str(pos + 1))

func _set_username(username: String) -> void:
	text = text.replace("{username}", username)

func _set_score(score: int) -> void:
	text = text.replace("{score}", str(int(score)))

func _set_skin(skin: String) -> void:
	if skin == "":
		text = text.replace("{skin}", "[img]res://hand sprites/open hand.png[/img]")
	else:
		text = text.replace("{skin}", "[img]res://hand sprites/open hand_" + skin + ".png[/img]")

func set_data(pos: int, username: String, score: int, skin: String) -> void:
	_set_pos(pos)
	_set_username(username)
	_set_score(score)
	_set_skin(skin)
