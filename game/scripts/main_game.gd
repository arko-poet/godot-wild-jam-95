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
var new_monster_stage := -1
var previous_monster_stage = -1
var base_transition_length: float = 0.75

@onready var win_lose_manager: Node = $WinLoseManager

@onready var pc_screen: Node2D = %PCScreen
@onready var monster: Sprite2D = %MonsterFinal
@onready var monster_transition: ColorRect = %MonsterTransition

@onready var claim_prize_button: Button = %ClaimPrizeButton
@onready var turn_on_pc_button: TextureButton = %TurnOnPCButton


func game_over() -> void:
	pass


func game_won() -> void:
	pass

func _ready() -> void:
	ProjectUISoundController.entity_steps_finished.connect(_on_entity_step_finished)
	
	turn_on_pc_button.grab_focus()
	monster.hide()

func _on_menu_button_pressed() -> void:
	pass # Replace with function body.

func _on_pc_screen_progress_bar_filled() -> void:
	monster.hide()
	SceneLoader.load_scene("res://template/scenes/end_credits/end_credits.tscn")
	#claim_prize_button.show()


func _on_pc_screen_doom_changed(percentage: float) -> void:
	if percentage < 0.1:
		return
	
	if percentage == 1.0:
		new_monster_stage = 5
	elif percentage >= 0.8:
		new_monster_stage = 4
	elif percentage >= 0.6:
		new_monster_stage = 3
	elif percentage >= 0.4:
		new_monster_stage = 2
	elif percentage >= 0.2:
		new_monster_stage= 1
	elif percentage >= 0.1:
		new_monster_stage = 0
	
	if new_monster_stage != monster_stage:
		#previous_monster_stage = monster_stage
		play_monster_transition()
	
	#monster.position = MONSTER_POSITIONS[monster_stage]
	#monster.scale = MONSTER_SCALES[monster_stage]
	#monster.show()

	if percentage == 1.0:
		# prevent game over showing immediatly before palyer sees final monster stage
		var timer = Timer.new()
		add_child(timer)
		timer.start(6.0)
		await timer.timeout
		win_lose_manager.game_lost()

func play_monster_transition() -> void:
	#monster_transition.visible = true
	
	#var tween := create_tween()
	GameplayAudioController.entity_step.emit()
	# add maybe a light flickering out sfx here, and a loud heartbeat as well to signify a bad decision
	# dark screen time increases as monster stage increase
	#tween.tween_interval(clampf(base_transition_length + monster_stage / 4.0, base_transition_length, base_transition_length + 2))
	#tween.tween_callback(func(): monster_transition.visible = false)

func _on_claim_prize_button_pressed() -> void:
	SceneLoader.load_scene("res://template/scenes/end_credits/end_credits.tscn")


func _on_turn_on_pc_button_pressed() -> void:
	if pc_screen.visible == false:
		pc_screen.play_power_on_animation()
	


func _on_entity_step_finished() -> void:
	monster_stage = new_monster_stage
	if monster_stage == 5:
		turn_on_pc_button.hide()
		monster.show()
