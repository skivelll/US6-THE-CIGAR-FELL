class_name ProgressState
extends RefCounted

var _abilities: Array[StringName] = []
var _artifacts: Array[StringName] = []

func reset() -> void:
	_abilities.clear()
	_artifacts.clear()

func unlock_ability(id: StringName) -> void:
	if id != &"" and not _abilities.has(id):
		_abilities.append(id)
		_abilities.sort()

func collect_artifact(id: StringName) -> void:
	if id != &"" and not _artifacts.has(id):
		_artifacts.append(id)
		_artifacts.sort()

func has_ability(id: StringName) -> bool:
	return _abilities.has(id)

func has_artifact(id: StringName) -> bool:
	return _artifacts.has(id)

func snapshot() -> Dictionary:
	var abilities: Array[String] = []
	for id: StringName in _abilities:
		abilities.append(String(id))
	var artifacts: Array[String] = []
	for id: StringName in _artifacts:
		artifacts.append(String(id))
	return {
		"abilities": abilities,
		"artifacts": artifacts,
	}
