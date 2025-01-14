extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGED,
	DEATH,
	SUMMONED
}


var state: int = IDLE:
	set(value):
		if state == DEATH:
			# Do not change state if already in DEATH
			return
		state = value	
		match state:
			CHASE: chase_state()
			IDLE: idle_state()	
			ATTACK: attack_state()
			DAMAGED: damage_state()
			DEATH: death_state()
			SUMMONED: summoned_state()

# Переменные
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_position  # Изменено на Vector2
var direction
var health = 100
var damage = 100
var speed = 60
var chase = false
var first_enter = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_player = $AnimationPlayer

func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	Signals.connect("player_attack", Callable(self, "_on_damage_received"))

func _physics_process(delta):
 # Применяем гравитацию, если персонаж не на полу
	if not is_on_floor():
		velocity.y += gravity * delta

	if state == CHASE:
		chase_state()

	move_and_slide()

func _on_player_position_update(player_pos): #Принимаем Vector2
	player_position = player_pos

func idle_state():
	velocity.x = 0
	animated_player.play("idle")
	await get_tree().create_timer(2).timeout
	$AttackDirection/AttackRange/CollisionShape2D.disabled = false
	if chase == true:
		state = CHASE
 
func attack_state():
	velocity.x = 0
	animated_player.play("attack")
	await animated_player.animation_finished
	$AttackDirection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE

func chase_state():
	animated_player.play("move")
	direction = (player_position - self.position).normalized() # Используем player_position
	if direction.x < 0:
		animated_sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		animated_sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	velocity.x = direction.x * speed  # Extracting the x component


func _on_hitbox_area_entered(area):
	Signals.emit_signal("enemy_attack", damage)


func _on_attack_range_body_entered(body: Node2D) -> void:
	state = ATTACK

func _on_damage_received(player_damage):
	health -= player_damage
	if health <= 0:
		state = DEATH
	else:
		state = DAMAGED
	print(health)

func damage_state():
	velocity.x = 0
	animated_player.play("hit")
	await animated_player.animation_finished
	state = IDLE
	
func death_state():
	velocity.x = 0
	animated_player.play("death")
	await animated_player.animation_finished
	queue_free()


func _on_detector_body_entered(body: Node2D) -> void:
	if chase == false:
		if first_enter == true:
			state = SUMMONED
			first_enter = false
		else:
			state = CHASE
	chase = true


func _on_detector_body_exited(body: Node2D) -> void:
	chase = false
	state = IDLE

func summoned_state():
	velocity.x = 0
	animated_player.play("summoned")
	await animated_player.animation_finished
	state = CHASE
	
	
