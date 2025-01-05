extends CharacterBody2D

enum {
	IDLE,
	MOVE,
	ATTACK
}

const SPEED = 80.0
const JUMP_VELOCITY = -250.0

var RUN_MULTIPLIER = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var state = MOVE
var current_attack = 1  # Текущая атака (1, 2 или 3)
var player_pos

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	match state:
		MOVE: move_state()
		ATTACK: attack_state()
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if velocity.y > 0 and state == MOVE:
		animated_sprite.play("fall")
	
	if health <= 0:
		health = 0
		animated_sprite.play("death")
		await animated_sprite.animation_finished
		queue_free()
		get_tree().reload_current_scene()
	
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)

func move_state():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * RUN_MULTIPLIER
		if velocity.y == 0:
			if RUN_MULTIPLIER == 1:
				animated_sprite.play("walk")
			else: 
				animated_sprite.play("run")
	else:	
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animated_sprite.play("idle")
	if direction == -1:
		animated_sprite.flip_h = true
		$DamageBox/HitBox.rotation_degrees = 180
	elif direction == 1:
		animated_sprite.flip_h = false
		$DamageBox/HitBox.rotation_degrees = 0
	if Input.is_action_pressed("run"):
		RUN_MULTIPLIER = 1.6
	else:
		RUN_MULTIPLIER = 1
	
	if Input.is_action_just_pressed("attack"):
		# Переход в состояние атаки
		state = ATTACK
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("fall")
		
func attack_state():
	if is_on_floor():
		var direction = Input.get_axis("move_left", "move_right")
		if direction == -1:
			velocity.x = -2			
		elif direction == 1:
			velocity.x = 2
			
	animated_sprite.play("attack" + str(current_attack))
	await animated_sprite.animation_finished
	
	# Переход к следующей атаке
	current_attack += 1
	if current_attack > 3:
		current_attack = 1
		

			
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("fall")
	# Возвращаемся в состояние движения
	state = MOVE
