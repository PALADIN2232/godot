extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -280.0
const RUN_MULTIPLIER = 1.33

var attack_animations = ["attack1", "attack2", "attack3"]
var current_attack = 0
var is_attacking = false  # Флаг для отслеживания атаки

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	# Если идет атака, блокируем управление
	if is_attacking:
		# На земле полностью блокируем горизонтальное движение
		if is_on_floor():
			velocity.x = 0
		else:
			# В воздухе сохраняем горизонтальную скорость
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)

		# Гравитация продолжает действовать
		velocity += get_gravity() * delta
		move_and_slide()
		return

	# Handle Jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_on_floor():  # Handle Horizontal Movement and Animation
		if direction != 0:
			velocity.x = direction * SPEED
			animated_sprite.flip_h = direction < 0
			if Input.is_action_pressed("run"):
				velocity.x *= RUN_MULTIPLIER
				animated_sprite.play("run")
			else:
				animated_sprite.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)  # Плавное торможение, если игрок остановился
			animated_sprite.play("idle")
	else:
		# While in the air, apply gravity and play the jumping animation
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("jumping")
		
		if Input.is_action_pressed("run"):
			velocity.x *= RUN_MULTIPLIER

	# Handle Attack
	if Input.is_action_pressed("attack"):
		start_attack()

	# Apply gravity regardless of state
	velocity += get_gravity() * delta
	
	move_and_slide()

func start_attack() -> void:
	# Запускаем атаку
	is_attacking = true
	# Останавливаем движение только на земле
	if is_on_floor():
		velocity.x = 0
	animated_sprite.play(attack_animations[current_attack])
	current_attack = (current_attack + 1) % attack_animations.size()

	# Подписываемся на сигнал завершения анимации
	$AnimatedSprite2D.animation_finished.connect(_on_attack_animation_finished)

func _on_attack_animation_finished() -> void:
	# Атака завершена
	is_attacking = false
