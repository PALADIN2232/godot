extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -280.0
const RUN_MULTIPLIER = 1.33

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

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
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	else:
		# While in the air, apply gravity and play the jumping animation
		velocity.x = direction * SPEED # No sideways movement while jumping
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("jumping")	
		if Input.is_action_pressed("run"):
			velocity.x *= RUN_MULTIPLIER
	
	

	# Apply gravity regardless of state
	velocity += get_gravity() * delta
	
	move_and_slide()
