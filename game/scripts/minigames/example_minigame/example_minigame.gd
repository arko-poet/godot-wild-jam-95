extends Minigame

const REQUIRED_SCORE := 10

var score := 0:
	set(value):
		score = value
		score_label.text = "Score: %s/%s" % [score, REQUIRED_SCORE]
		if score >= REQUIRED_SCORE:
			game_won.emit()
					
@onready var score_label: Label = %ScoreLabel


func _on_add_score_button_pressed() -> void:
	score += 1
