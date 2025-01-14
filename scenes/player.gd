extends CharacterBody2D

signal health_changed

enum {
	IDLE,
	MOVE,
	ATTACK,
	DAMAGED,
	DEATH
}

const SPEED = 60.0
const JUMP_VELOCITY = -270.0

var RUN_MULTIPLIER = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_health = 100
var health = 100
var state = MOVE
var current_attack = 1  # Текущая атака (1, 2 или 3)
var player_pos
var damage = 30

@onready var animated_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	health = max_health
	Signals.connect("enemy_attack", Callable(self, "_on_damage_received"))

func _physics_process(delta: float) -> void:
	match state:
		MOVE: move_state()
		ATTACK: attack_state()
		DAMAGED: damage_state()
		DEATH: death_state()
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if velocity.y > 0 and state == MOVE:
		animated_player.play("fall")
	
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)

func move_state():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * RUN_MULTIPLIER
		if velocity.y == 0:
			if RUN_MULTIPLIER == 1:
				animated_player.play("walk")
			else: 
				animated_player.play("run")
	else:	
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animated_player.play("idle")
	if direction == -1:
		animated_sprite.flip_h = true
		$DamageBox/Hitbox.rotation_degrees = 180
	elif direction == 1:
		animated_sprite.flip_h = false
		$DamageBox/Hitbox.rotation_degrees = 0
	if Input.is_action_pressed("run"):
		RUN_MULTIPLIER = 2
	else:
		RUN_MULTIPLIER = 1
	
	if Input.is_action_just_pressed("attack"):
		# Переход в состояние атаки
		state = ATTACK
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_player.play("jumping")
		
func attack_state():
	if is_on_floor():
		var direction = Input.get_axis("move_left", "move_right")
		if direction == -1:
			velocity.x = -2			
		elif direction == 1:
			velocity.x = 2
			
	animated_player.play("attack" + str(current_attack))
	await animated_player.animation_finished
	
	# Переход к следующей атаке
	current_attack += 1
	if current_attack > 3:
		current_attack = 1
		

			
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_player.play("fall")
	# Возвращаемся в состояние движения
	state = MOVE
	
func damage_state():
	velocity.x = 0
	$DamageBox/Hurtbox/CollisionShape2D.disabled = true
	animated_player.play("damaged")
	await animated_player.animation_finished
	state = MOVE
	await get_tree().create_timer(1).timeout
	$DamageBox/Hurtbox/CollisionShape2D.disabled = false
	

func _on_damage_received(enemy_damage):
	health -= enemy_damage
	health_changed.emit()
	if health == 0:
		state = DEATH
	else:
		state = DAMAGED
	print(health)
	
func death_state():
	velocity.x = 0
	animated_player.play("death")
	await animated_player.animation_finished
	queue_free()
	get_tree().reload_current_scene()


func _on_hitbox_area_entered(area):
	Signals.emit_signal("player_attack", damage)
