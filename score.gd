extends Area2D

var score = 0

func reset_score() -> void:
	score = 0
	$Label.text = str(score)

func increase_score(amount: int) -> void:
	score += amount
	$Label.text = str(score)
