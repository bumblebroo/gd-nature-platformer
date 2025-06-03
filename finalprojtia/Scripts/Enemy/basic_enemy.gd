extends Node2D

@export var max_hp : int

var current_hp : int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
	current_hp = max_hp

func take_damage(damage):
	current_hp -= damage
	
	if current_hp <= 0:
		queue_free()
