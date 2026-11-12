class_name EpilogueController
extends RefCounted

signal epilogue_started
signal epilogue_completed_signal
signal video_opened

const DEFAULT_SLIDES: Array[StringName] = [
	&"watchman",
	&"portak",
	&"lisa",
	&"shizik_and_followers",
	&"sanboy",
	&"yulia_and_watchman",
]

var main_run_completed: bool = false
var epilogue_started_once: bool = false
var epilogue_completed: bool = false
var epilogue_index: int = -1
var epilogue_slides: Array[StringName] = DEFAULT_SLIDES.duplicate()
var video_available: bool = false
var video_opened_once: bool = false
var video_launch_count: int = 0

func play() -> bool:
	if not main_run_completed or epilogue_started_once:
		return false
	epilogue_started_once = true
	epilogue_completed = false
	epilogue_index = -1
	epilogue_started.emit()
	for index: int in epilogue_slides.size():
		epilogue_index = index
	epilogue_completed = true
	video_available = true
	epilogue_completed_signal.emit()
	return true

func replay() -> bool:
	if not main_run_completed or not epilogue_completed:
		return false
	epilogue_index = -1
	for index: int in epilogue_slides.size():
		epilogue_index = index
	epilogue_completed = true
	return true

func open_video() -> bool:
	if not video_available or not epilogue_completed:
		return false
	video_opened_once = true
	video_launch_count += 1
	video_opened.emit()
	return true
