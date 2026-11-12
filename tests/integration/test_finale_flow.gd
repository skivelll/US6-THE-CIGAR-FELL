class_name FinaleFlowTests
extends RefCounted

const FinaleFlowScript = preload("res://scripts/finale/finale_flow.gd")
const BaseControllerScript = preload("res://scripts/base/base_controller.gd")

var failures: Array[String] = []

func run() -> Array[String]:
	failures.clear()
	test_finale_requires_all_artifacts()
	test_confirmation_starts_finale_and_then_locks_movement()
	test_phases_follow_strict_order()
	test_sanboy_appears_only_after_watchman()
	test_lisa_and_shizik_are_not_finale_roster()
	test_portak_and_watchman_are_freed_after_their_phases()
	test_ritual_preserves_yulia_and_tattoos_while_clearing_mutation()
	test_complete_ritual_is_idempotent_and_completes_main_run()
	return failures

func _progress_with_all_artifacts() -> ProgressState:
	var progress := ProgressState.new()
	for artifact_id: StringName in [&"cigar_cutter", &"ashtray", &"lighter_heart", &"mouthpiece"]:
		progress.collect_artifact(artifact_id)
	return progress

func _new_flow(progress: ProgressState) -> RefCounted:
	return FinaleFlowScript.new(progress, BaseControllerScript.new())

func test_finale_requires_all_artifacts() -> void:
	var progress := ProgressState.new()
	progress.collect_artifact(&"cigar_cutter")
	var flow = _new_flow(progress)
	_check(not flow.start(), "finale rejects missing artifacts")
	_check(not flow.confirm_start(), "confirmation cannot bypass missing artifacts")
	_check(not flow.finale_started, "finale remains stopped without artifacts")
	_check(not flow.free_movement_locked, "movement remains free while finale is unavailable")

func test_confirmation_starts_finale_and_then_locks_movement() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	_check(not flow.start(), "start shows confirmation instead of starting immediately")
	_check(flow.confirmation_required, "start exposes explicit confirmation requirement")
	_check(not flow.free_movement_locked, "movement is free before confirmation")
	_check(flow.confirm_start(), "explicit confirmation starts finale")
	_check(flow.finale_started, "finale is marked started")
	_check(flow.free_movement_locked, "movement locks only after confirmation")
	_check(not flow.confirm_start(), "confirmation cannot restart finale")

func test_phases_follow_strict_order() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	flow.start()
	flow.confirm_start()
	_check(flow.current_phase == &"portak", "finale starts with Portak")
	_check(not flow.complete_phase(&"watchman"), "Watchman cannot complete before Portak")
	_check(flow.complete_phase(&"portak"), "Portak phase completes first")
	_check(flow.current_phase == &"watchman", "Watchman follows Portak")
	_check(not flow.complete_phase(&"sanboy"), "Sanboy cannot complete before Watchman")
	_check(flow.complete_phase(&"watchman"), "Watchman phase completes second")
	_check(flow.current_phase == &"sanboy", "Sanboy follows Watchman")
	_check(flow.complete_phase(&"sanboy"), "Sanboy phase completes third")
	_check(flow.current_phase == &"", "no combat phase remains after Sanboy")

func test_sanboy_appears_only_after_watchman() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	flow.start()
	flow.confirm_start()
	_check(not flow.sanboy_visible, "Sanboy is hidden before the Watchman phase")
	flow.complete_phase(&"portak")
	_check(not flow.sanboy_visible, "Sanboy is hidden during Watchman phase")
	flow.complete_phase(&"watchman")
	_check(flow.sanboy_visible, "Sanboy appears after Watchman is defeated")

func test_lisa_and_shizik_are_not_finale_roster() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	_check(not flow.finale_roster.has(&"lisa"), "Lisa is not in finale roster")
	_check(not flow.finale_roster.has(&"shizik"), "Shizik is not in finale roster")
	_check(flow.finale_roster == [&"portak", &"watchman", &"sanboy"], "finale roster contains only approved phases")

func test_portak_and_watchman_are_freed_after_their_phases() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	flow.start()
	flow.confirm_start()
	flow.complete_phase(&"portak")
	_check(flow.portak_freed, "Portak is freed after the first phase")
	flow.complete_phase(&"watchman")
	_check(flow.watchman_freed, "Watchman is freed after the second phase")

func test_ritual_preserves_yulia_and_tattoos_while_clearing_mutation() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	flow.start()
	flow.confirm_start()
	flow.complete_phase(&"portak")
	flow.complete_phase(&"watchman")
	flow.complete_phase(&"sanboy")
	_check(flow.yulia_alive, "Yulia survives before ritual completion")
	_check(flow.complete_ritual(), "ritual completes after all phases")
	_check(flow.yulia_alive, "Yulia survives the ritual")
	_check(flow.mutation_cleared, "dangerous mutation is cleared")
	_check(flow.harmless_tattoos_preserved, "harmless tattoo motion is preserved")

func test_complete_ritual_is_idempotent_and_completes_main_run() -> void:
	var flow = _new_flow(_progress_with_all_artifacts())
	flow.start()
	flow.confirm_start()
	flow.complete_phase(&"portak")
	flow.complete_phase(&"watchman")
	flow.complete_phase(&"sanboy")
	var completion_count: Array[int] = [0]
	flow.ritual_completed.connect(func() -> void: completion_count[0] += 1)
	_check(flow.complete_ritual(), "first ritual completion succeeds")
	_check(flow.main_run_completed, "main run is marked completed")
	_check(flow.complete_ritual(), "repeated ritual completion is harmless")
	_check(completion_count[0] == 1, "ritual completion is emitted once")
	_check(flow.main_run_completed, "repeated ritual completion keeps main run completed")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
