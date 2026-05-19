extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Gamemanager.add_energy_cell()
		queue_free()
