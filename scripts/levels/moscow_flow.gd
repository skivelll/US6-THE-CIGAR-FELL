class_name MoscowFlow
extends RefCounted

const ROOM_ORDER: Array[StringName] = [&"lightroom", &"rolex", &"nikolskaya", &"construction"]

var progress: ProgressState
var current_room: StringName = &"lightroom"
var _room_index: int = 0

func _init(progress_state: ProgressState = null) -> void:
	progress = progress_state if progress_state != null else ProgressState.new()

func create_coal_sword() -> void:
	progress.unlock_ability(&"combat")
	progress.unlock_ability(&"normal_attack")
	progress.unlock_ability(&"strong_attack")

func enter_room(room: StringName) -> bool:
	if _room_index >= ROOM_ORDER.size() - 1:
		return false
	if ROOM_ORDER[_room_index + 1] != room:
		return false
	_room_index += 1
	current_room = room
	return true

func complete_level() -> void:
	progress.collect_artifact(&"cigar_cutter")
	current_room = &"base"
