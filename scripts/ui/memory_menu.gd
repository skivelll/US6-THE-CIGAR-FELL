class_name MemoryMenu
extends RefCounted

signal menu_opened
signal replay_started(level_id: StringName)

const MEMORY_IDS: Array[StringName] = [&"moscow", &"warehouse", &"ryazan", &"danang", &"finale"]

var main_progress: ProgressState
var replay_progress: ProgressState
var main_run_completed: bool = false
var last_replay_id: StringName = &""
var replay_count: int = 0

func _init(progress: ProgressState = null) -> void:
	main_progress = progress if progress != null else ProgressState.new()

func available_memories() -> Array[StringName]:
	if not main_run_completed:
		return []
	menu_opened.emit()
	return MEMORY_IDS.duplicate()

func replay_level(level_id: StringName) -> bool:
	if not main_run_completed or not MEMORY_IDS.has(level_id):
		return false
	replay_progress = ProgressState.new()
	last_replay_id = level_id
	replay_count += 1
	replay_started.emit(level_id)
	return true
