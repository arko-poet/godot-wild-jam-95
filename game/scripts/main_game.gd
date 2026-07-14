extends Node

const MONSTER_POSITIONS := [
	Vector2(1064, 366),
	Vector2(1096, 375),
	Vector2(1096, 375),
	Vector2(900, 377),
	Vector2(1108, 486),
	Vector2(1005, 328)
]
const MONSTER_SCALES := [
	Vector2(0.5, 0.5),
	Vector2(0.5, 0.5),
	Vector2(0.5, 0.5),
	Vector2(0.75, 0.75),
	Vector2(2.0, 2.0),
	Vector2(3.0, 3.0)
]

var monster_stage := -1

@onready var win_lose_manager: Node = $WinLoseManager

@onready var pc_screen: Node2D = %PCScreen
@onready var monster: Sprite2D = %Monster

@onready var claim_prize_button: Button = %ClaimPrizeButton


func game_over() -> void:
	pass


func game_won() -> void:
	pass


func _on_menu_button_pressed() -> void:
	pass # Replace with function body.


func _on_pc_screen_progress_bar_filled() -> void:
	claim_prize_button.show()


func _on_pc_screen_doom_changed(percentage: float) -> void:
	if percentage == 1.0:
		monster_stage = 5
	elif percentage >= 0.8:
		monster_stage = 4
	elif percentage >= 0.6:
		monster_stage = 3
	elif percentage >= 0.4:
		monster_stage = 2
	elif percentage >= 0.2:
		monster_stage = 1
	elif percentage >= 0.1:
		monster_stage = 0
	
	monster.position = MONSTER_POSITIONS[monster_stage]
	monster.scale = MONSTER_SCALES[monster_stage]
	monster.show()

	if percentage == 1.0:
		win_lose_manager.game_lost()

func _on_claim_prize_button_pressed() -> void:
	SceneLoader.load_scene("res://template/scenes/end_credits/end_credits.tscn")
