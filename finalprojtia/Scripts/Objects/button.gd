extends Node2D

signal button_pressed
signal button_released

var pressed : bool = false

@export var press_duration : float = 1

@onready var press_timer : Timer = $Press_timer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func press_button():
	## If the button has already been pressed, reset the pressed timer                                                                                                                                 
	if pressed:
		press_timer.start()
		return
	
	# Emit signal
	button_pressed.emit()
	
	## Prep and start timer
	press_timer.wait_time = press_duration
	press_timer.start()
	
	# Set correct sprite
	sprite.play("pushed")
	
	pressed = true

func _on_press_timer_timeout() -> void:
	# Emit signal
	button_released.emit()
	
	# Set correct sprite
	sprite.play("default")
	
	pressed = false
