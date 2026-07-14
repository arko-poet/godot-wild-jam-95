extends CharacterBody2D

const MOVE_SPEED = 400.0 ## Move speed, higher means faster
const JUMP_VELOCITY = -350.0 ## jump height, should be negative, lower means jump higher
const KNOCKBACK_DIST = 200.0 ## How far back the player is knocked when colliding with an obstacle

# all of these can be updated for whatever input action strings are for these buttons
const INPUT_JUMP: StringName = "ui_up"
const INPUT_RIGHT: StringName = "ui_right"
const INPUT_LEFT: StringName = "ui_left"

var stunned := false # if true, player is stunned and cannot move
var invincible := false # if true, player just exited stun and is in a brief invulnerable period
var direction := 0.0 # the movement direction on the X axis the player input
var knockback_speed_mult := 1.0 # used to slow down the knockback over time, MUST be 1.0 when not stunned

var _vel: Vector2 ## holds the results from get_real_velocity() in _process()
var _rot_mult: float ## rotation degrees gets multiplied by this value
var _is_on_floor: bool ## set to the result of is_on_floor() in _physics_process()
var _control_mult: float

# rotates the sprite based on how fast the player is moving
func _process(delta: float) -> void:
	_vel = get_real_velocity()
	if is_on_floor():
		_rot_mult = 0.8
	else:
		_rot_mult = 0.16
	$Sprite2D.rotation_degrees += delta * _vel.x * _rot_mult


func _physics_process(delta: float) -> void:
	direction = Input.get_axis(INPUT_LEFT, INPUT_RIGHT)
	_is_on_floor = is_on_floor()
	
	if stunned:
		# when stunned we just slow the player's knockback down each frame
		if _is_on_floor:
			knockback_speed_mult = clamp(knockback_speed_mult - (delta * 0.05), 0.7, 1.0)
		
	else:
		# basic platformer movement code here
		if _is_on_floor:
			if Input.is_action_just_pressed(INPUT_JUMP):
				velocity.y = JUMP_VELOCITY
			_control_mult = 1.0
		else:
			_control_mult = 0.5
		if direction:
			velocity.x = direction * MOVE_SPEED * _control_mult
		else:
			velocity.x = move_toward(velocity.x, 0, MOVE_SPEED * _control_mult)
		
	
	# you always fall regardless of stun status
	if !_is_on_floor:
		velocity += get_gravity() * delta
	
	
	# hurting the player will set the velocity so we run this right before move_and_slide 
	if !stunned and !invincible:
		for i in get_slide_collision_count():
			var _col = get_slide_collision(i)
			if _col:
				if _col.get_collider() is FallingGameSpike:
					hurt()
	
	velocity.x *= knockback_speed_mult # this is why this variable must be 1.0 when not stunned
	move_and_slide()

# sets timers and resets variables, plus triggers a manual knockback effect
func hurt() -> void:
	stunned = true
	$StunTimer.start() # adjust this timer to change stun time
	knockback_speed_mult = 1.0
	modulate = Color.CRIMSON
	if direction >= 0.0:
		velocity = Vector2(-1.0, -1.0) * KNOCKBACK_DIST
	else:
		velocity = Vector2(1.0, -1.0) * KNOCKBACK_DIST

# no longer stunned, change state and start invincible period
func _on_stun_timer_timeout() -> void:
	stunned = false
	invincible = true
	$InvincibleTimer.start() # adjust this timer to change invincible time
	modulate = Color.DIM_GRAY
	knockback_speed_mult = 1.0

# no longer stunned, back to normal
func _on_invincible_timer_timeout() -> void:
	invincible = false
	modulate = Color.WHITE
