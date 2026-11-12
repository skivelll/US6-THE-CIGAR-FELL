class_name WarehouseFlow
extends RefCounted

const LanaEncounterScript = preload("res://scripts/encounters/lana_encounter.gd")

const ROOM_ORDER: Array[StringName] = [&"warehouse_exterior", &"kitten_hydra", &"papy_flowers", &"skelberry", &"lana"]

var progress: ProgressState
var current_room: StringName = &"warehouse_exterior"
var portak_rescued: bool = false
var _room_index: int = 0

func _init(progress_state: ProgressState = null) -> void:
	progress = progress_state if progress_state != null else ProgressState.new()

func enter_room(room: StringName) -> bool:
	if _room_index >= ROOM_ORDER.size() - 1 or ROOM_ORDER[_room_index + 1] != room:
		return false
	_room_index += 1
	current_room = room
	return true

func complete_kittens(boss: RefCounted) -> void:
	if boss.is_defeated():
		progress.unlock_ability(&"combo")
		current_room = &"kitten_hydra"

func complete_papy_flowers(boss: RefCounted) -> void:
	if boss.is_defeated():
		progress.unlock_ability(&"air_strong")
		current_room = &"papy_flowers"

func complete_skelberry(boss: RefCounted) -> void:
	if boss.is_defeated():
		progress.unlock_ability(&"use_potion")
		portak_rescued = true
		current_room = &"skelberry"

func complete_lana(encounter: RefCounted) -> void:
	if encounter.is_completed():
		current_room = &"lana"

func complete_level() -> void:
	progress.collect_artifact(&"ashtray")
	current_room = &"base"
