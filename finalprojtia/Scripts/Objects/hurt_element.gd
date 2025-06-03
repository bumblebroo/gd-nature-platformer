extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("found player")
	if body.has_method("player_take_damage"):
		print("damaging player")
		body.player_take_damage()
