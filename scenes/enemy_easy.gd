extends CharacterBody2D

enum {
<<<<<<< HEAD
 IDLE,
 ATTACK,
 CHASE
=======
	IDLE,
	ATTACK,
	CHASE
>>>>>>> 8d674cae0dad2a3d9df5b801d6755c34bdb96e05
}

var state: int = IDLE:
	set(value):
		state = value
		match state:
<<<<<<< HEAD
			IDLE: idle_state()	
=======
			IDLE: idle_state()
>>>>>>> 8d674cae0dad2a3d9df5b801d6755c34bdb96e05
			ATTACK: attack_state()

# Переменные
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
<<<<<<< HEAD
var player_position: Vector2  # Изменено на Vector2
var direction

@onready var attack_area = $DamageBox/HitBox/CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))

func _physics_process(delta):
 # Применяем гравитацию, если персонаж не на полу
	if not is_on_floor():
		velocity.y += gravity * delta

	if state == CHASE:
		chase_state()

	move_and_slide()

func _on_player_position_update(player_pos : Vector2): #Принимаем Vector2
	player_position = player_pos

func idle_state():
	animated_sprite.play("idle")
	await get_tree().create_timer(2).timeout
	attack_area.disabled = false
	state = CHASE
 
func attack_state():
	animated_sprite.play("attack1")	
	await animated_sprite.animation_finished
	attack_area.disabled = true
	state = IDLE

func chase_state():
	direction = (player_position - self.position).normalized() # Используем player_position
	if state != ATTACK:
		if direction.x < 0:
			animated_sprite.flip_h = true
			$DamageBox/HitBox.rotation_degrees = 180
		else:
			animated_sprite.flip_h = false
			$DamageBox/HitBox.rotation_degrees = 0



func _on_hit_box_body_entered(body):
	state = ATTACK
=======

@onready var attack_area = $DamageBox/HitBox/CollisionShape2D
@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D	

func _physics_process(delta):
	# Применяем гравитацию, если персонаж не на полу
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func idle_state():
	animated_sprite.play("idle")
	
func attack_state():
	animated_sprite.play("attack1")

func _on_hit_box_body_entered(body):
	state = ATTACK

func _on_hit_box_body_exited(body: Node2D) -> void:
		state = IDLE	

func _on_animation_finished():
	state = IDLE
>>>>>>> 8d674cae0dad2a3d9df5b801d6755c34bdb96e05
