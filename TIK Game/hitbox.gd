extends Area2D
class_name Hitbox

func _ready() -> void:
	set_active(false)

func set_active(boolean: bool):
	for child in get_children():
		if child is not CollisionShape2D: continue
