extends CharacterBody2D

signal died
signal health_changed(current: int, maximum: int)

const WALK_SPEED: float = 180.0
const RUN_SPEED: float = 320.0
const JUMP_VELOCITY: float = -520.0
const GRAVITY: float = 1200.0
const MAX_HP: int = 5
const DODGE_COOLDOWN: float = 0.8
const DODGE_INVINCIBILITY: float = 0.4
const DODGE_SPEED: float = 600.0

var hp: int = MAX_HP
var is_dead: bool = false
var is_dodging: bool = false
var _dodge_cooldown: float = 0.0
var _invincibility_timer: float = 0.0
var _dodge_timer: float = 0.0
var _dodge_direction: float = 1.0

func _ready() -> void:
	health_changed.emit(hp, MAX_HP)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_dodge_cooldown = maxf(_dodge_cooldown - delta, 0.0)
	_invincibility_timer = maxf(_invincibility_timer - delta, 0.0)
	if is_dodging:
		_dodge_timer -= delta
		velocity.x = _dodge_direction * DODGE_SPEED
		if _dodge_timer <= 0.0:
			is_dodging = false
	else:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		var direction: float = Input.get_axis("move_left", "move_right")
		var speed: float = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
		velocity.x = direction * speed
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("dodge") and _dodge_cooldown <= 0.0 and direction != 0.0:
			_start_dodge(direction)
	move_and_slide()

func _start_dodge(direction: float) -> void:
	is_dodging = true
	_dodge_direction = direction
	_dodge_timer = DODGE_INVINCIBILITY
	_invincibility_timer = DODGE_INVINCIBILITY
	_dodge_cooldown = DODGE_COOLDOWN

func take_damage(amount: int) -> void:
	if is_dead or _invincibility_timer > 0.0 or amount <= 0:
		return
	hp = maxi(hp - amount, 0)
	health_changed.emit(hp, MAX_HP)
	if hp == 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	_respawn_after_delay()

func _respawn_after_delay() -> void:
	if not is_inside_tree():
		return
	await get_tree().create_timer(1.0).timeout
	respawn()

func respawn() -> void:
	global_position = _get_respawn_position()
	velocity = Vector2.ZERO
	hp = MAX_HP
	is_dead = false
	is_dodging = false
	_invincibility_timer = 0.0
	health_changed.emit(hp, MAX_HP)

func _get_respawn_position() -> Vector2:
	if is_inside_tree():
		var manager: Node = get_node_or_null("/root/CheckpointManagerSingleton")
		if manager != null and manager.has_method("get_respawn_position"):
			return manager.get_respawn_position() as Vector2
	return Vector2(100.0, 300.0)
