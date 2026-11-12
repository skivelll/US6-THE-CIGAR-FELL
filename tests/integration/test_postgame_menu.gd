class_name PostgameMenuTests
extends RefCounted

const EpilogueControllerScript = preload("res://scripts/epilogue/epilogue_controller.gd")
const MemoryMenuScript = preload("res://scripts/ui/memory_menu.gd")
const PerformanceProbeScript = preload("res://scripts/platform/performance_probe.gd")

var failures: Array[String] = []

func run() -> Array[String]:
	failures.clear()
	test_epilogue_locked_until_main_run_completed()
	test_epilogue_order_and_warm_final_frame()
	test_video_is_available_and_repeatable()
	test_memory_menu_locked_until_main_run_completed()
	test_all_memories_are_replayable()
	test_replay_isolated_from_main_progress_and_repeatable()
	test_unknown_replay_is_rejected()
	test_performance_probe_schema_and_budget()
	return failures

func test_epilogue_locked_until_main_run_completed() -> void:
	var controller = EpilogueControllerScript.new()
	_check(not controller.play(), "epilogue is unavailable before main run completion")
	controller.main_run_completed = true
	_check(controller.play(), "epilogue becomes available after main run completion")

func test_epilogue_order_and_warm_final_frame() -> void:
	var controller = EpilogueControllerScript.new()
	controller.main_run_completed = true
	_check(controller.play(), "epilogue starts")
	_check(controller.epilogue_slides == [&"watchman", &"portak", &"lisa", &"shizik_and_followers", &"sanboy", &"yulia_and_watchman"], "epilogue uses exact deterministic order")
	_check(controller.epilogue_index == controller.epilogue_slides.size() - 1, "epilogue ends on final slide")
	_check(controller.epilogue_slides[controller.epilogue_index] == &"yulia_and_watchman", "final frame is Yulia and Watchman")
	_check(controller.epilogue_completed, "epilogue completes")

func test_video_is_available_and_repeatable() -> void:
	var controller = EpilogueControllerScript.new()
	controller.main_run_completed = true
	controller.play()
	_check(controller.video_available, "video is available after epilogue")
	_check(controller.open_video(), "video opens after epilogue")
	_check(controller.open_video(), "video can be opened repeatedly")
	_check(controller.video_launch_count == 2, "video launch count is observable")

func test_memory_menu_locked_until_main_run_completed() -> void:
	var menu = MemoryMenuScript.new()
	_check(menu.available_memories().is_empty(), "memory menu is empty before main run")
	menu.main_run_completed = true
	_check(menu.available_memories().size() == 5, "memory menu opens after main run")

func test_all_memories_are_replayable() -> void:
	var menu = MemoryMenuScript.new()
	menu.main_run_completed = true
	for level_id: StringName in [&"moscow", &"warehouse", &"ryazan", &"danang", &"finale"]:
		_check(menu.replay_level(level_id), "replay starts for " + String(level_id))

func test_replay_isolated_from_main_progress_and_repeatable() -> void:
	var main_progress := ProgressState.new()
	main_progress.unlock_ability(&"combo")
	main_progress.collect_artifact(&"mouthpiece")
	var before: Dictionary = main_progress.snapshot()
	var menu = MemoryMenuScript.new(main_progress)
	menu.main_run_completed = true
	_check(menu.replay_level(&"moscow"), "moscow replay starts")
	_check(menu.replay_progress != main_progress, "replay has a separate ProgressState")
	_check(menu.replay_progress.snapshot() == {"abilities": [], "artifacts": []}, "replay starts without abilities or artifacts")
	_check(main_progress.snapshot() == before, "replay leaves main progress unchanged")
	_check(not menu.replay_progress.has_artifact(&"mouthpiece"), "replay does not inherit main artifacts")
	_check(not menu.main_run_completed == false, "main completion gate remains true")
	_check(menu.replay_level(&"moscow"), "same replay can start again")

func test_unknown_replay_is_rejected() -> void:
	var menu = MemoryMenuScript.new()
	menu.main_run_completed = true
	_check(not menu.replay_level(&"unknown"), "unknown replay ID is rejected")

func test_performance_probe_schema_and_budget() -> void:
	var probe = PerformanceProbeScript.new()
	probe.sampler = func(_duration: float) -> Dictionary:
		return {"average_frame_time_ms": 10.0, "peak_frame_time_ms": 20.0, "peak_active_enemies": 12, "peak_particles": 80, "draw_calls": 90}
	var result: Dictionary = probe.sample(2.0)
	for key: String in [&"duration_seconds", &"average_frame_time_ms", &"peak_frame_time_ms", &"peak_active_enemies", &"peak_particles", &"draw_calls", &"within_budget"]:
		_check(result.has(key), "performance result has " + key)
	_check(result.duration_seconds == 2.0, "performance reports requested duration")
	_check(result.within_budget, "bounded sample is within budget")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
