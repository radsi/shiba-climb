@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("Jigsaw Puzzle", "Pasta", preload("puzzle.gd"), preload("icon.png"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
