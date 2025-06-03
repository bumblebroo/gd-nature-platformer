extends CharacterBody2D
class_name Player

## Constants
const SPEED : float = 150.0
const ACCELERATION_TIME : float = 0.1
const DEACCELERATION_TIME : float = 0.05
const JUMP_VELOCITY : float = -270.0

const FALL_MULTIPLIER : float = 2.5
const LOW_JUMP_MULTIPLIER : float = 2
const COYOTE_TIME : float = 0.2

const MAX_DASHES : int = 1
const DASH_SPEED : float = 250
const DASH_DURATION : float = 0.2
const DASH_COOLDOWN : float = 1.1
const DASH_DAMAGE : int = 1

const BOUNCE_MULTIPLIER : float = 0.8

## References
@onready var dash_duration_timer : Timer = $Timers/dash_duration
@onready var dash_cooldown_timer : Timer = $Timers/dash_cd
@onready var coyote_time_timer : Timer = $Timers/coyote_time

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var attack_area : Area2D = $attack_area

## Variables
var direction : float = 0
var last_dir : float = 1

var current_coins : int = 0

@onready var dashes_left : int = MAX_DASHES
var dash_called : bool = false
var dashing : bool = false

var can_jump : bool = false
var jump_called : bool = false

var gravity_to_apply : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	handle_input(delta)
	handle_movement(delta)
	move_and_slide()

func handle_input(delta: float):
	# Arrange for the correct gravity to be applied
	if not is_on_floor() and not dashing:
		if Input.is_action_pressed("Jump"):
			gravity_to_apply = get_gravity() * delta
		elif velocity.y > 0:
			gravity_to_apply = get_gravity() * delta * LOW_JUMP_MULTIPLIER
		else:
			gravity_to_apply = get_gravity() * delta * FALL_MULTIPLIER
	else:
		gravity_to_apply = Vector2.ZERO
	
	# Check if can jump
	if is_on_floor():
		can_jump = true
	# Gives additional time for the player to jump after leaving a platform
	elif coyote_time_timer.time_left == 0 and can_jump == true:
		coyote_time_timer.wait_time = COYOTE_TIME
		coyote_time_timer.start()
	
	# Call Jump
	if Input.is_action_just_pressed("Jump") and can_jump:
		jump_called = true
		can_jump = false
	
	## Gets Horizontal input along with applying the correct animations
	direction = Input.get_axis("GoLeft", "GoRight")
	if direction != 0 and not dashing:
		last_dir = direction
		
		# Flip sprite to face the correct direction
		animated_sprite.flip_h = direction == -1
		
		attack_area.position = Vector2(direction * 3, attack_area.position.y)
		
		if dashes_left > 0:
			animated_sprite.play("runCharged")
		else:
			animated_sprite.play("runNotCharged")
	elif not dashing:
		if dashes_left > 0:
			animated_sprite.play("defaultCharged")
		else:
			animated_sprite.play("defaultNotCharged")
	else:
		animated_sprite.play("dash")
	
	# Call the dash
	if Input.is_action_just_pressed("Action") and dashes_left > 0:
		dash_called = true


func handle_movement(delta: float):
	# Apply gravity
	if gravity_to_apply != Vector2.ZERO:
		velocity += gravity_to_apply
	
	# Apply jump logic
	if jump_called:
		velocity.y = JUMP_VELOCITY
		jump_called = false
	
	# Handle dash logicad
	if dash_called:
		dashing = true
		dash_called = false
		dashes_left -= 1
		
		dash_cooldown_timer.wait_time = DASH_COOLDOWN
		dash_cooldown_timer.start()
		
		dash_duration_timer.wait_time = DASH_DURATION
		dash_duration_timer.start()
		
		velocity.y = 0
	
	# Handles movement logic
	if dashing:
		velocity.x = last_dir * DASH_SPEED
		attack_area.monitoring = true
		
	elif direction != 0:
		velocity.x = lerpf(velocity.x, direction * SPEED, delta / ACCELERATION_TIME)
	else:
		velocity.x = lerpf(velocity.x, 0, delta / DEACCELERATION_TIME)

func pick_up_coin():
	current_coins += 1
	print("picked up coin")

func player_take_damage():
	if not dashing:
		get_tree().reload_current_scene()

# Stops dashing once duration is finished
func _on_dash_duration_timer_timeout() -> void:
	dashing = false
	attack_area.monitoring = false

# Resets dash after timer is done
func _on_dash_cd_timeout() -> void:
	dashes_left = MAX_DASHES

## Handling inputs from the attack_area
func _on_attack_area_body_entered(body: Node2D) -> void:
	if dashing:
		if body.owner.has_method("take_damage"):
			body.owner.take_damage(DASH_DAMAGE)
			print("did damage")
		if body.owner.has_method("press_button"):
			body.owner.press_button()
		velocity.x *= -1.6
		dashing = false
		attack_area.monitoring = false


func _on_coyote_time_timeout() -> void:
	can_jump = false
