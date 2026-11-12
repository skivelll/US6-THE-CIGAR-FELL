class_name EncounterPhase
extends RefCounted

var required_enemies: Array[StringName] = []
var defeated_enemies: Array[StringName] = []
var started: bool = false

func _init(required: Array[StringName] = []) -> void:
	required_enemies = required.duplicate()

func start() -> void:
	started = true

func enemy_defeated(enemy_id: StringName) -> bool:
	if not started or not required_enemies.has(enemy_id) or defeated_enemies.has(enemy_id):
		return false
	defeated_enemies.append(enemy_id)
	return true

func is_complete() -> bool:
	return started and defeated_enemies.size() >= required_enemies.size()
