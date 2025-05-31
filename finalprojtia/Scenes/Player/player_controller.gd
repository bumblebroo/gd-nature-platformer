extends CharacterBody2D

## Constants
const SPEED : float = 230.0
const ACCELERATION_TIME : float = 0.1
const DEACCELERATION_TIME : float = 0.05
const JUMP_VELOCITY : float = -350.0

const FALL_MULTIPLIER : float = 2.5
const LOW_JUMP_MULTIPLIER : float = 2

const MAX_DASHES : int = 1
const DASH_SPEED : float = 400
const DASH_DURATION : float = 0.3
const DASH_COOLDOWN : float = 2

const BOUNCE_MULTIPLIER : float = 0.8

## References
@onready var dash_duration_timer : Timer = $dash_duration
@onready var dash_cooldown_timer : Timer = $dash_cd

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var attack_area : Area2D = $attack_area

## Variables
var direction : float = 0
var last_dir : float = 1

@onready var dashes_left : int = MAX_DASHES
var dash_called : bool = false
var dashing : bool = false

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
	
	# Call Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		jump_called = true
	
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
		velocity.x = lerpf(velocity.x, last_dir * DASH_SPEED, delta / ACCELERATION_TIME)
		
	elif direction != 0:
		velocity.x = lerpf(velocity.x, direction * SPEED, delta / ACCELERATION_TIME)
	else:
		velocity.x = lerpf(velocity.x, 0, delta / DEACCELERATION_TIME)
	


func _on_dash_duration_timer_timeout() -> void:
	dashing = false

func _on_dash_cd_timeout() -> void:
	dashes_left = MAX_DASHES

func _on_attack_area_body_entered(body: Node2D) -> void:
	if dashing:
		#body.queue_free()
		velocity.x *= -2
		dashing = false
