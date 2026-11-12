class_name PlayerStats
extends RefCounted

signal health_changed(current_hp: int, maximum_hp: int)
signal died
signal respawned

const MAX_HP: int = 100

var max_hp: int = MAX_HP
var hp: int = MAX_HP
var is_dead: bool = false
var respawn_position: Vector2 = Vector2.ZERO
var progress_state: ProgressState = ProgressState.new()

func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	hp = maxi(hp - amount, 0)
	health_changed.emit(hp, max_hp)
	if hp == 0:
		is_dead = true
		died.emit()

func set_respawn_position(position: Vector2) -> void:
	respawn_position = position

func respawn() -> Vector2:
	hp = max_hp
	is_dead = false
	health_changed.emit(hp, max_hp)
	respawned.emit()
	return respawn_position
