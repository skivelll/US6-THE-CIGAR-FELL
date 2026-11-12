class_name FinaleFlow
extends RefCounted

const BaseControllerScript = preload("res://scripts/base/base_controller.gd")

signal phase_started(id: StringName)
signal phase_completed(id: StringName)
signal ritual_completed

const phases: Array[StringName] = [&"portak", &"watchman", &"sanboy"]
const finale_roster: Array[StringName] = [&"portak", &"watchman", &"sanboy"]

var progress: ProgressState
var base_controller: BaseController
var current_phase: StringName = &""
var finale_started: bool = false
var confirmation_required: bool = false
var free_movement_locked: bool = false
var main_run_completed: bool = false
var mutation_cleared: bool = false
var harmless_tattoos_preserved: bool = false
var yulia_alive: bool = true
var sanboy_visible: bool = false
var portak_freed: bool = false
var watchman_freed: bool = false
var ritual_completed_once: bool = false

func _init(progress_state: ProgressState = null, controller: BaseController = null) -> void:
	progress = progress_state if progress_state != null else ProgressState.new()
	base_controller = controller if controller != null else BaseControllerScript.new()

func start() -> bool:
	if finale_started or not _has_all_artifacts():
		return false
	confirmation_required = true
	return false

func confirm_start() -> bool:
	if finale_started or not confirmation_required or not _has_all_artifacts():
		return false
	confirmation_required = false
	finale_started = true
	free_movement_locked = true
	current_phase = phases[0]
	phase_started.emit(current_phase)
	return true

func complete_phase(id: StringName) -> bool:
	if not finale_started or ritual_completed_once or current_phase != id:
		return false
	phase_completed.emit(id)
	if id == &"portak":
		portak_freed = true
	elif id == &"watchman":
		watchman_freed = true
		sanboy_visible = true
	elif id == &"sanboy":
		current_phase = &""
		return true
	var phase_index: int = phases.find(id)
	if phase_index < 0 or phase_index + 1 >= phases.size():
		return false
	current_phase = phases[phase_index + 1]
	phase_started.emit(current_phase)
	return true

func complete_ritual() -> bool:
	if ritual_completed_once:
		return true
	if not finale_started or current_phase != &"":
		return false
	ritual_completed_once = true
	yulia_alive = true
	mutation_cleared = true
	harmless_tattoos_preserved = true
	main_run_completed = true
	ritual_completed.emit()
	return true

func _has_all_artifacts() -> bool:
	for artifact_id: StringName in BaseControllerScript.REQUIRED_ARTIFACTS:
		if not progress.has_artifact(artifact_id):
			return false
	return true
