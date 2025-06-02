extends Node2D

signal button_pressed
signal button_released

@export var press_duration = 1

@onready var press_timer = $Timer

func press_button():
	button_pressed.emit()
	
	## Prep timer
	press_timer.wait_time = press_duration
	press_timer.start()
