class_name RyazanFlowTests
extends RefCounted

const RyazanFlowScript = preload("res://scripts/levels/ryazan_flow.gd")
const LisaBossScript = preload("res://scripts/encounters/lisa_boss.gd")

var failures: Array[String] = []

func run() -> Array[String]:
	failures.clear()
	test_route_requires_order()
	test_lisa_starts_in_lisa_phase()
	test_break_crown_enters_system_phase_once()
	test_lisa_is_removed_from_second_phase_roster()
	test_there_is_no_third_phase()
	test_second_phase_completion_is_idempotent()
	test_level_completion_grants_lighter_heart_once()
	return failures

func test_route_requires_order() -> void:
	var flow = RyazanFlowScript.new()
	_check(not flow.enter_room(&"attic"), "route rejects attic before bridge")
	_check(flow.enter_room(&"bridge"), "route enters bridge")
	_check(flow.enter_room(&"attic"), "route enters attic")
	_check(flow.enter_room(&"roof"), "route enters roof")
	_check(flow.enter_room(&"zazhigalka"), "route enters zazhigalka")
	_check(not flow.enter_room(&"roof"), "route cannot go backwards")

func test_lisa_starts_in_lisa_phase() -> void:
	var boss = LisaBossScript.new()
	_check(boss.current_phase == boss.phase_lisa, "Lisa starts in phase_lisa")

func test_break_crown_enters_system_phase_once() -> void:
	var boss = LisaBossScript.new()
	_check(boss.break_crown(), "first break_crown succeeds")
	_check(boss.current_phase == boss.phase_system, "crown break enters phase_system")
	_check(not boss.break_crown(), "second break_crown is ignored")
	_check(boss.current_phase == boss.phase_system, "second break preserves phase_system")

func test_lisa_is_removed_from_second_phase_roster() -> void:
	var boss = LisaBossScript.new()
	_check(boss.second_phase_roster.has(&"watermelon_ketchup_system"), "system is in second phase roster")
	_check(not boss.second_phase_roster.has(&"lisa"), "Lisa is absent from second phase roster")
	boss.break_crown()
	_check(not boss.second_phase_roster.has(&"lisa"), "Lisa remains absent after crown break")

func test_there_is_no_third_phase() -> void:
	var boss = LisaBossScript.new()
	_check(boss.phases.size() == 2, "Lisa boss exposes exactly two phases")
	_check(not boss.phases.has(&"phase_third"), "Lisa boss has no third phase")
	_check(not boss.has_method("start_third_phase"), "Lisa boss has no third phase transition")

func test_second_phase_completion_is_idempotent() -> void:
	var boss = LisaBossScript.new()
	boss.break_crown()
	_check(boss.complete_system_phase(), "first system phase completion succeeds")
	_check(boss.is_defeated(), "boss is defeated after system phase")
	_check(not boss.complete_system_phase(), "second system phase completion is ignored")
	_check(boss.is_defeated(), "boss remains defeated")

func test_level_completion_grants_lighter_heart_once() -> void:
	var progress := ProgressState.new()
	var flow = RyazanFlowScript.new(progress)
	flow.enter_room(&"bridge")
	flow.enter_room(&"attic")
	flow.enter_room(&"roof")
	flow.enter_room(&"zazhigalka")
	var boss = LisaBossScript.new()
	boss.break_crown()
	boss.complete_system_phase()
	flow.complete_lisa_boss(boss)
	_check(progress.has_artifact(&"lighter_heart"), "victory grants lighter_heart")
	flow.complete_level()
	flow.complete_level()
	_check(progress.artifacts.count(&"lighter_heart") == 1, "lighter_heart is granted exactly once")
	_check(flow.current_room == &"base", "completed level transitions to base")
	boss.free()

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
