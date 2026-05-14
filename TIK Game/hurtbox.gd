extends Area2D
class_name Hurtbox

signal hurt()
signal died()

@export var healthpoints:= 3

func get_damage(value: int):
	healthpoints -= value
	hurt.emit()
	
	if healthpoints <= 0:
		died.emit
