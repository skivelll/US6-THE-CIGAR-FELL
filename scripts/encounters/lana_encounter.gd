class_name LanaEncounter
extends RefCounted

const SONG_COUNT: int = 3
var phase_count: int = SONG_COUNT
var phase_index: int = 0
var arena_revision: int = 0
var wave_composition: Array[StringName] = [&"kittens"]
var smoke_returned: bool = false
var ashtray_ready: bool = false
var _started: bool = false
var _wave_cleared: bool = false
var _completed: bool = false

func start() -> void:
	_started = true

func on_wave_cleared() -> void:
	if not _started or _completed:
		return
	_wave_cleared = true
	if phase_index == SONG_COUNT - 1:
		complete()

func advance_song() -> bool:
	if not _started or _completed or not _wave_cleared or phase_index >= SONG_COUNT - 1:
		return false
	phase_index += 1
	arena_revision += 1
	wave_composition = [&"kittens"]
	if phase_index >= 1:
		wave_composition.append(&"papy_flowers")
	if phase_index >= 2:
		wave_composition.append(&"skelberry")
	_wave_cleared = false
	return true

func complete() -> void:
	if _completed:
		return
	_completed = true
	smoke_returned = true
	ashtray_ready = true

func is_completed() -> bool:
	return _completed
