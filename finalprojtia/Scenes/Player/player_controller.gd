extends CharacterBody2D


const SPEED = 300.0
const ACCELERATION = 10
const DEACCELERATION = 15 
const JUMP_VELOCITY = -500.0

const FALL_MULTIPLIER = 2.5
const LOW_JUMP_MULTIPLIER = 2


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("Jump"):
			velocity += get_gravity() * delta
		elif velocity.y > 0:
			velocity += get_gravity() * delta * LOW_JUMP_MULTIPLIER
		else:
			velocity += get_gravity() * delta * FALL_MULTIPLIER


	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("GoLeft", "GoRight")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
