extends Node2D
@export var Player : Player
@export var animation_player: AnimationPlayer
@export var sprite : Sprite2D
@onready var jumpsound: AudioStreamPlayer2D = $"../Jumpsound"

func _process(delta):
	#flips character
	if Player.direction == 1:
		sprite.flip_h = false
	elif Player.direction == -1:
		sprite.flip_h = true
		
	#movement anims
	if abs(Player.velocity.x) > 0.0:
		animation_player.play("run")
	else:
		animation_player.play("idle")
		
	#jump anim
	if Player.velocity.y < 0.0:
		animation_player.play("jumping")

	elif Player.velocity.y > 0.0:
		animation_player.play("jumping")
	
