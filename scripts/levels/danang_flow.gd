class_name DanangFlow
extends RefCounted

const ROOM_ORDER: Array[StringName] = [&"arrival", &"backstreet", &"entertainment_house", &"syringe_arena"]

var progress: ProgressState
var current_room: StringName = &""
var shizik_personally_met := false
var rescued_shizik := false
var shizik_arrived_at_base := false
var unnamed_followers_arrived_at_base := false
var presentation_state: StringName = &""
var syringe_defeated := false
var _room_index := -1
var _level_completed := false

func _init(progress_state: ProgressState = null) -> void:
	progress = progress_state if progress_state != null else ProgressState.new()

func enter_room(room: StringName) -> bool:
	if _room_index >= ROOM_ORDER.size() - 1 or ROOM_ORDER[_room_index + 1] != room:
		return false
	_room_index += 1
	current_room = room
	return true

func complete_syringe_boss(boss: Object) -> void:
	if current_room != &"syringe_arena" or not boss.is_defeated():
		return
	if syringe_defeated:
		return
	syringe_defeated = true
	boss.cut_into_mouthpiece()
	shizik_personally_met = true
	rescued_shizik = true
	shizik_arrived_at_base = true
	unnamed_followers_arrived_at_base = true
	presentation_state = &"remote_safe_entertainment"

func complete_level() -> void:
	if not syringe_defeated:
		return
	if not _level_completed:
		progress.collect_artifact(&"mouthpiece")
		_level_completed = true
	current_room = &"base"
