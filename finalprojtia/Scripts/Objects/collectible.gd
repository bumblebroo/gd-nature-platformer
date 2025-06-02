extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("touched")
	if body.owner.has_method("pick_up_coin"):
		print("has method")
		body.owner.has_method("pick_up_coin")
		queue_free()
