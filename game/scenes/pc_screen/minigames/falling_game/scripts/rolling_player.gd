class_name RollingPlayer extends CharacterBody2D

const MOVE_SPEED_RAMP = 3.0 ## How quickly the player's momentum increases or decreases
const AIR_CONTROL = 0.7 ## How much the player can influence direction while airborne, 1.0 is full control
const MAX_MOVE_SPEED = 500.0 ## The fastest the move speed can be in either direction
const JUMP_VELOCITY = -300.0 ## jump height, should be negative, lower means jump higher
const KNOCKBACK_DIST = 175.0 ## How far back the player is knocked when colliding with an obstacle
const ROLLING_FRICTION = 300.0 ## How much reduction in speed the player gets while on the ground and not accelerating

# all of these can be updated for whatever input action strings are for these buttons
const INPUT_JUMP: StringName = "ui_up"
const INPUT_RIGHT: StringName = "ui_right"
const INPUT_LEFT: StringName = "ui_left"

var stunned := false # if true, player is stunned and cannot move
var invincible := false # if true, player just exited stun and is in a brief invulnerable period

var _direction: float ## the movement direction on the X axis the player input
var _vel: Vector2 ## holds the results from get_real_velocity() in _process()
var _is_on_floor: bool ## set to the result of is_on_floor() in _physics_process()
var _x: float ## added to velocity.x on each frame
var _knockback_speed_mult := 1.0 ## When in the stunned state, velocity.x is multiplied by this value
var _x_mod: float ## added or subtracted to _x in _physics_process() when the player is in control
var _spike_check: float ## used to hold the data needed to detect and react to knockbacks

# rotates the sprite based on how fast the player is moving
func _process(delta: float) -> void:
	_vel = get_real_velocity()
	if is_on_floor():
		%Sprite2D.rotation_degrees += delta * _vel.x * 0.8
	else:
		%Sprite2D.rotation_degrees += delta * _vel.x * 0.16
	

func _physics_process(delta: float) -> void:
	# first set the variables that need to be checked each frame
	_direction = Input.get_axis(INPUT_LEFT, INPUT_RIGHT)
	_is_on_floor = is_on_floor()
	_spike_check = _check_for_spikes()
	
	# code here is when player is in control
	if !stunned:
		_x_mod = _direction * delta * MOVE_SPEED_RAMP * MAX_MOVE_SPEED
		if _is_on_floor:
			if Input.is_action_just_pressed(INPUT_JUMP):
				velocity.y = JUMP_VELOCITY
		else:
			_x_mod *= AIR_CONTROL
		_x = clamp(_x + _x_mod, MAX_MOVE_SPEED * -1, MAX_MOVE_SPEED)
		if is_on_wall() and _is_on_floor and _spike_check == 0.0 and _direction == 0.0:
			_x = 0.0
	
	# have to fall no matter what
	if !_is_on_floor:
		velocity += get_gravity() * delta
	
	
	if !stunned:
		# set velocity to knockback if player runs into spikes, otherwise just apply _x
		# that was modified in the player control code block
		if _spike_check != 0.0:
			velocity = _knockback(_spike_check)
		else:
			velocity.x = _x
	else:
		# if we are in a stunned state, velocity just slows down creating a rolling away effect
		# which basically ignores any code that may have been set
		if _is_on_floor:
			_knockback_speed_mult = clamp(_knockback_speed_mult - (delta * 0.05), 0.7, 1.0)
			velocity.x *= _knockback_speed_mult
	
	move_and_slide()
	
	if _is_on_floor and _direction == 0.0:
		if _x > 0:
			_x = clamp(_x - (ROLLING_FRICTION * delta), 0, INF)
		else:
			_x = clamp(_x + (ROLLING_FRICTION * delta), -INF, 0)

## If the player is colliding with a spike it returns 1.0 if it is to the left of the player or
## -1.0 if it is to the right. If there is no collision, or player is invincible, returns 0.0
func _check_for_spikes() -> float:
	if invincible: return 0.0
	for i in get_slide_collision_count():
			var _col = get_slide_collision(i)
			if _col:
				var _col_obj = _col.get_collider()
				if _col_obj is FallingGameSpike:
					if _col_obj.global_position.x >= global_position.x:
						return -1.0
					else:
						return 1.0
	return 0.0

## Runs all code for the knockback and returns what should be the velocity for this physics frame
## must be passed the data returned from _check_for_spikes() which should be a 1.0 or -1.0
func _knockback(_knockback_direction: float) -> Vector2:
	assert(_knockback_direction == 1.0 or _knockback_direction == -1.0, "_knockback() was called on rolling player with a value of %s" % _knockback_direction)
	stunned = true
	_knockback_speed_mult = 1.0
	_x = 0.0
	%StunTimer.start() # adjust this timer to change stun time
	modulate = Color.CRIMSON
	
	GameplayAudioController.minigame_bad_event.emit()
	
	return Vector2(_knockback_direction, -1.0) * KNOCKBACK_DIST


# no longer stunned, change state and start invincible period
func _on_stun_timer_timeout() -> void:
	stunned = false
	invincible = true
	%InvincibleTimer.start() # adjust this timer to change invincible time
	modulate = Color.DIM_GRAY
	_x = get_real_velocity().x


# no longer stunned, back to normal
func _on_invincible_timer_timeout() -> void:
	invincible = false
	modulate = Color.WHITE
