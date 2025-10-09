extends Node

@onready var bg1 = $Bg
@onready var bg2 = $Bg2
@onready var entries_container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
var entry = preload("res://prefabs/leaderboard/label.tscn")

func _ready() -> void:
	$AnimationPlayer.play("arrow_back")
	bg1.global_position.y = globals.current_menu_bg_pos[0]
	bg2.global_position.y = globals.current_menu_bg_pos[1]
	await _load_entries()

func _process(delta: float) -> void:
	bg1.global_position.y += 5
	bg2.global_position.y += 5
	
	if bg1.global_position.y > 2156:
		bg1.global_position.y = -2156
	if bg2.global_position.y > 2156:
		bg2.global_position.y = -2156
	
	globals.current_menu_bg_pos[0] = bg1.global_position.y
	globals.current_menu_bg_pos[1] = bg2.global_position.y

func _create_entry(_entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry.instantiate()

	var skin = ""
	if _entry.props.size() > 0:
		skin = _entry.props[0].value

	entry_instance.set_data(_entry.position, _entry.player_alias.identifier, _entry.score, skin)
	entries_container.add_child(entry_instance)


func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	for entry in Talo.leaderboards.get_cached_entries("handware-leaderboard"):
		_create_entry(entry)

func _load_entries() -> void:
	var page = 0
	var done = false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page

		var res := await Talo.leaderboards.get_entries("handware-leaderboard", options)
		var entries: Array[TaloLeaderboardEntry] = res.entries
		var count: int = res.count
		var is_last_page: bool = res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

		_build_entries()
		
func _on_buttonback_pressed() -> void:
	globals._play_pop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_buttonback_mouse_entered() -> void:
	if $buttonback != null:
		$buttonback.scale = Vector2(1.15,1.15)

func _on_buttonback_mouse_exited() -> void:
	if $buttonback != null:
		$buttonback.scale = Vector2(1,1)
