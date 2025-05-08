extends CharacterBody2D

## Constants
const SPEED : float = 300.0
const ACCELERATION_TIME : float = 0.1
const DEACCELERATION_TIME : float = 0.05
const JUMP_VELOCITY : float = -500.0

const FALL_MULTIPLIER : float = 2.5
const LOW_JUMP_MULTIPLIER : float = 2

const MAX_DASHES : int = 1
const DASH_FORCE : float = 1000
## References

## Variables
var dashes_left : int = 0

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		if Input.is_action_pressed("Jump"):
			velocity += get_gravity() * delta
		elif velocity.y > 0:
			velocity += get_gravity() * delta * LOW_JUMP_MULTIPLIER
		else:
			velocity += get_gravity() * delta * FALL_MULTIPLIER
	# Reset dashes when touching floor
	else:
		dashes_left = MAX_DASHES


	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	## Gets Horizontal input
	var direction := Input.get_axis("GoLeft", "GoRight")
	
	# Handles dashes
	if Input.is_action_just_pressed("Action") and dashes_left > 0:
		velocity.x += direction * DASH_FORCE
		dashes_left -= 1
	
	# Handles movement logic
	if direction:
		velocity.x = lerpf(velocity.x, direction * SPEED, delta / ACCELERATION_TIME)
	else:
		velocity.x = lerpf(velocity.x, 0, delta / DEACCELERATION_TIME)

	move_and_slide()
