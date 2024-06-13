extends Node2D

signal new_game
signal quit_game

func _on_new_game_pressed() -> void:
	emit_signal("new_game")

func _on_quit_game_pressed() -> void:
	emit_signal("quit_game")

func _on_visibility_changed() -> void:
	if visible:
		$NewGame.grab_focus()
		$NewGame.grab_click_focus()
