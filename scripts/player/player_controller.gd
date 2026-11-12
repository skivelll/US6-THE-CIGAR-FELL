class_name PlayerController
extends CharacterBody2D

const PlayerStatsScript = preload("res://scripts/player/player_stats.gd")

signal died
signal respawned

const WALK_SPEED: float = 200.0
const RUN_SPEED: float = 350.0
const JUMP_VELOCITY: float = -500.0
const DODGE_SPEED: float = 500.0
const DODGE_DURATION: float = 0.25
const DOUBLE_TAP_WINDOW: float = 0.25
const GRAVITY: float = 980.0
const MAX_HP: int = 100

var stats: RefCounted = PlayerStatsScript.new()
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_direction: float = 1.0
var checkpoint_position: Vector2 = Vector2.ZERO
var _last_direction: float = 0.0
var _last_tap_time: float = -1.0

var hp: int:
	get:
		return stats.hp
	set(value):
		stats.hp = clampi(value, 0, stats.max_hp)

var is_dead: bool:
	get:
		return stats.is_dead
	set(value):
		stats.is_dead = value

func _ready() -> void:
	if not stats.died.is_connected(_on_stats_died):
		stats.died.connect(_on_stats_died)
	if not stats.respawned.is_connected(_on_stats_respawned):
		stats.respawned.connect(_on_stats_respawned)

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
	if direction == 0.0:
		direction = Input.get_axis("ui_left", "ui_right")
	var running: bool = Input.is_action_pressed("run")
	var speed: float = RUN_SPEED if running else WALK_SPEED
	velocity.x = direction * speed
	if is_on_floor() and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept")):
		velocity.y = JUMP_VELOCITY
	if is_on_floor() and _dodge_requested(direction):
		_start_dodge(direction)
	move_and_slide()

func _dodge_requested(direction: float) -> bool:
	if Input.is_action_just_pressed("dodge") and direction != 0.0:
		return true
	if direction == 0.0 or direction == _last_direction:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	var is_double_tap: bool = now - _last_tap_time <= DOUBLE_TAP_WINDOW
	_last_tap_time = now
	_last_direction = direction
	return is_double_tap

func _start_dodge(direction: float) -> void:
	is_dodging = true
	dodge_timer = DODGE_DURATION
	dodge_direction = direction

func take_damage(amount: int) -> void:
	if is_dodging:
		return
	stats.take_damage(amount)

func die() -> void:
	if is_dead:
		return
	stats.take_damage(stats.hp)

func respawn() -> void:
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	stats.respawn()

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos
	stats.set_respawn_position(pos)

func configure(progress: ProgressState) -> void:
	stats.progress_state = progress

func use_ability(id: StringName) -> bool:
	return stats.progress_state.has_ability(id)

func _on_stats_died() -> void:
	died.emit()

func _on_stats_respawned() -> void:
	respawned.emit()
