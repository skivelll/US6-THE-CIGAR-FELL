extends Node

signal checkpoint_activated(id: StringName)

const DEFAULT_RESPAWN_POSITION: Vector2 = Vector2(100.0, 300.0)

var _checkpoints: Dictionary = {}
var _current_id: StringName = &""

func register_checkpoint(id: StringName, position: Vector2) -> void:
	if id != &"":
		_checkpoints[id] = position

func activate_checkpoint(id: StringName) -> void:
	if not _checkpoints.has(id):
		return
	_current_id = id
	checkpoint_activated.emit(id)

func get_respawn_position() -> Vector2:
	if _checkpoints.has(_current_id):
		return _checkpoints[_current_id] as Vector2
	return DEFAULT_RESPAWN_POSITION

func reset() -> void:
	_checkpoints.clear()
	_current_id = &""
