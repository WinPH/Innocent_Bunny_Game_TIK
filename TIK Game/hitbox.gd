# Hitbox2D.gd - Attach to Area2D
extends Area2D
class_name Hitbox2D

@export var damage: int = 10
@export var knockback_force: float = 300.0
@export var hitstun_frames: int = 15
@export var active_duration: float = 0.2
@onready var hurtbox: Hurtbox2D = $"../Hurtbox"
@onready var hitbox: Hitbox2D = $"."



signal hit_confirmed(hurtbox: Hurtbox2D, hitbox: Hitbox2D)

var is_active: bool = false
var timer: Timer

func _ready():
	# Don't monitor by default
	monitoring = false
	collision_mask = 2
	
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_deactivate)

func activate():
	if is_active: return
	
	is_active = true
	monitoring = true
	modulate = Color(0.815, 0.0, 0.188, 0.8) 
	
	timer.start(active_duration)

func _deactivate():
	is_active = false
	monitoring = false
	modulate = Color.WHITE

func _on_area_entered(area: Area2D):
	if not is_active: return
	
	var hurtbox = area as Hurtbox2D
	if hurtbox and hurtbox.can_take_damage():
		hit_confirmed.emit(hurtbox, self)
		hurtbox.take_hit(self)
