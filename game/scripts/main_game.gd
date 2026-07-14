extends Node

@onready var pc_screen: Node2D = %PCScreen
@onready var claim_prize_button: Button = %ClaimPrizeButton


func game_over() -> void:
	pass


func game_won() -> void:
	pass


func _on_menu_button_pressed() -> void:
	pass # Replace with function body.


func _on_pc_screen_progress_bar_filled() -> void:
	print("progress filled")
	claim_prize_button.show()


func _on_pc_screen_doom_changed(percentage: float) -> void:
	pass # Replace with function body.


func _on_claim_prize_button_pressed() -> void:
	SceneLoader.load_scene("res://template/scenes/end_credits/end_credits.tscn")
