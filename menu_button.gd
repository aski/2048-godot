extends Button

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	elif event.is_action_pressed("action"):
		if self.has_focus():
			emit_signal("pressed")
