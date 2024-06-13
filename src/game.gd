extends Node2D

var menu_active = false

func _ready() -> void:
	$Board.score_increased.connect(_on_score_increased)
	$Board.score_reset.connect(_on_board_score_reset)
	$Board.game_finished.connect(_on_board_game_finished)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		toggle_menu(!menu_active)

func _on_board_score_reset() -> void:
	$Score.reset_score()

func _on_score_increased(amount) -> void:
	$Score.increase_score(amount)

func _on_board_game_finished() -> void:
	toggle_menu(true)
	
func _on_menu_new_game() -> void:
	$Board.reset_game()
	toggle_menu(false)

func _on_menu_quit_game() -> void:
	get_tree().quit()
	
func toggle_menu(enabled: bool) -> void:
	if enabled and menu_active:
		return
	elif enabled:
		menu_active = true
		$Menu.visible = true
		$Board.active = false
	elif not enabled:
		menu_active = false
		$Menu.visible = false
		$Board.active = true
