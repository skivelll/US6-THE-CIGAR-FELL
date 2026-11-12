class_name EncounterController
extends RefCounted

signal phase_started(index: int)
signal completed

var phases: Array = []
var current_phase_index: int = -1
var _completed: bool = false

func _init(phase_list: Array = []) -> void:
	phases = phase_list.duplicate()

func start() -> void:
	if phases.is_empty() or _completed:
		return
	current_phase_index = 0
	phases[current_phase_index].start()
	phase_started.emit(current_phase_index)

func on_enemy_defeated(enemy_id: StringName) -> void:
	if _completed or current_phase_index < 0:
		return
	var phase = phases[current_phase_index]
	phase.enemy_defeated(enemy_id)
	if phase.is_complete():
		advance_phase()

func advance_phase() -> void:
	if _completed or current_phase_index < 0:
		return
	if not phases[current_phase_index].is_complete():
		return
	current_phase_index += 1
	if current_phase_index >= phases.size():
		_completed = true
		completed.emit()
		return
	phases[current_phase_index].start()
	phase_started.emit(current_phase_index)

func is_completed() -> bool:
	return _completed
