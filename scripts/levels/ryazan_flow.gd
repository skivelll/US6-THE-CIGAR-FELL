class_name RyazanFlow
extends RefCounted

const ROOM_ORDER: Array[StringName] = [&"bridge", &"attic", &"roof", &"zazhigalka"]

var progress: ProgressState
var current_room: StringName = &""
var lisa_defeated := false
var slideshow_requested := false
var _room_index := -1

func _init(progress_state: ProgressState = null) -> void:
	progress = progress_state if progress_state != null else ProgressState.new()

func enter_room(room: StringName) -> bool:
	if _room_index >= ROOM_ORDER.size() - 1 or ROOM_ORDER[_room_index + 1] != room:
		return false
	_room_index += 1
	current_room = room
	return true

func complete_lisa_boss(boss: Object) -> void:
	if current_room != &"zazhigalka" or not boss.is_defeated():
		return
	lisa_defeated = true
	complete_level()

func complete_level() -> void:
	if not lisa_defeated:
		return
	progress.collect_artifact(&"lighter_heart")
	slideshow_requested = true
	current_room = &"base"
