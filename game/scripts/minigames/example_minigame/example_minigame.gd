extends Minigame

const REQUIRED_SCORE := 10

var score := 0:
	set(value):
		score = value
		score_label.text = "Score: %s/10" % score
		if score >= REQUIRED_SCORE:
			game_won.emit()
		
@onready var score_label: Label = %ScoreLabel


func setup() -> void:
	score = 0


func _on_button_pressed() -> void:
	score += 1
