# Hurtbox2D.gd - Attach to Area2D
extends Area2D
class_name Hurtbox2D

@export var max_health: int = 100
@export var invuln_frames: float = 0.6

signal health_changed(health: int, max_health: int)
signal took_damage(damage: int, knockback: Vector2, hitstun: int)
signal died()

var current_health: int
var is_invulnerable: bool = false
var invuln_timer: Timer
var damage_flash_tween: Tween

func _ready():
	current_health = max_health
	collision_layer = 2  # Hurtbox layer
	
	# Invulnerability timer
	invuln_timer = Timer.new()
	invuln_timer.one_shot = true
	add_child(invuln_timer)
	invuln_timer.timeout.connect(_end_invulnerability)

func can_take_damage() -> bool:
	return not is_invulnerable

func take_hit(hitbox: Hitbox2D):
	if not can_take_damage():
		return
	
	# Apply damage
	current_health -= hitbox.damage
	current_health = max(0, current_health)
	
	# Emit signals
	health_changed.emit(current_health, max_health)
	var knockback = (global_position.direction_to(hitbox.global_position) * hitbox.knockback_force)
	took_damage.emit(hitbox.damage, knockback, hitbox.hitstun_frames)
	
	# Visual & invulnerability
	_damage_flash()
	_start_invulnerability()
	
	if current_health <= 0:
		died.emit()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func _start_invulnerability():
	is_invulnerable = true
	invuln_timer.start(invuln_frames)
	modulate.a = 0.5
	collision_layer = 0  # Disable collision

func _end_invulnerability():
	is_invulnerable = false
	modulate.a = 1.0
	collision_layer = 2  # Re-enable collision

func _damage_flash():
	if damage_flash_tween:
		damage_flash_tween.kill()
	
	damage_flash_tween = create_tween()
	damage_flash_tween.tween_property(self, "modulate", Color.RED, 0.1)
	damage_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.1)
