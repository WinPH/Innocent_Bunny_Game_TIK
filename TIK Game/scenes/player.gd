extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jumpsound: AudioStreamPlayer2D = $Jumpsound
@onready var scarysound: AudioStreamPlayer2D = $Scarysound
@onready var hitbox: Hitbox = $Hitbox
@export var max_health: float = 100.0
@export var current_health: float = 100.0 : set = set_current_health
@export var invincible_time: float = 1.0
@export var damage_flash_color: Color = Color.RED

# Signals
signal health_changed(new_health: float, max_health: float)
signal health_depleted()
signal healed(amount: float)
signal damaged(amount: float)
signal died()

# Internal variables
var is_invincible: bool = false
var damage_flash_timer: float = 0.0
var invincibility_timer: Timer

@onready var sprite: Sprite2D = $Sprite2D  # Adjust path to your sprite

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	# Create invincibility timer
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	add_child(invincibility_timer)
	invincibility_timer.timeout.connect(_invincibility_ended)

func _process(delta):
	if damage_flash_timer > 0:
		damage_flash_timer -= delta
		if sprite:
			sprite.modulate = damage_flash_color if fmod(damage_flash_timer, 0.1) < 0.05 else Color.WHITE

func set_current_health(value: float):
	current_health = clampf(value, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		health_depleted.emit()
		died.emit()
		set_physics_process(false)

## Public methods for health management

func take_damage(amount: float):
	if is_invincible or amount <= 0:
		return
	
	current_health -= amount
	damaged.emit(amount)
	
	# Start invincibility timer
	is_invincible = true
	damage_flash_timer = invincible_time
	invincibility_timer.start(invincible_time)

func heal(amount: float):
	if amount <= 0:
		return
	
	var old_health = current_health
	current_health += amount
	healed.emit(amount)

func full_heal():
	var old_health = current_health
	current_health = max_health
	healed.emit(max_health - old_health)

func is_dead() -> bool:
	return current_health <= 0

func is_full_health() -> bool:
	return current_health >= max_health

func get_health_ratio() -> float:
	return current_health / max_health

## Private methods

func _invincibility_ended():
	is_invincible = false

func _input(event):
	if event.is_action_pressed("heal_test"):
		heal(2.0)
	if event.is_action_pressed("damage_test"):
		take_damage(2.0)
	if event.is_action_pressed("full_heal_test"):
		full_heal()

const SPEED = 300.0
const JUMP_VELOCITY = -600


func _physics_process(delta: float) -> void:
	#add animatioin
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"
	
	if Input.is_action_just_pressed("attack"):
		animated_sprite_2d.animation = "attack"
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumpsound.play()
		animated_sprite_2d.animation = "jumping"

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true


func _on_hurtbox_died() -> void:
	animated_sprite_2d.play("death")


func _on_hurtbox_hurt() -> void:
	animated_sprite_2d.play("hurt")


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	var attackanimation = animated_sprite_2d.animation == "attack"
	var frame = animated_sprite_2d.frame

	if attackanimation:
		if frame == 1:
			hitbox.set_active(true)
		elif frame == 0:
			hitbox.set_active(false)
