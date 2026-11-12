class_name PlayerController
extends CharacterBody2D

signal died
signal respawned

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -450.0
const RUN_MULTIPLIER: float = 1.6
const DODGE_SPEED: float = 400.0
const DODGE_DURATION: float = 0.25
const GRAVITY: float = 980.0
const MAX_HP: int = 3

var hp: int = MAX_HP
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_direction: float = 1.0
var is_dead: bool = false
var checkpoint_position: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if is_dodging:
		dodge_timer -= delta
		velocity.x = dodge_direction * DODGE_SPEED
		if dodge_timer <= 0.0:
			is_dodging = false
		move_and_slide()
		return
	var direction: float = Input.get_axis("move_left", "move_right")
	var running: bool = Input.is_action_pressed("run")
	var speed: float = SPEED * (RUN_MULTIPLIER if running else 1.0)
	velocity.x = direction * speed
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	if is_on_floor() and Input.is_action_just_pressed("dodge") and direction != 0.0:
		is_dodging = true
		dodge_timer = DODGE_DURATION
		dodge_direction = direction
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead or is_dodging:
		return
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	emit_signal("died")

func respawn() -> void:
	hp = MAX_HP
	is_dead = false
	velocity = Vector2.ZERO
	if checkpoint_position != Vector2.ZERO:
		global_position = checkpoint_position
	emit_signal("respawned")

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos
