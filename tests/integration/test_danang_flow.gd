class_name DanangFlowTests
extends RefCounted

const DanangFlowScript = preload("res://scripts/levels/danang_flow.gd")
const SyringeBossScript = preload("res://scripts/encounters/syringe_boss.gd")

var failures: Array[String] = []

func run() -> Array[String]:
	failures.clear()
	test_route_requires_order()
	test_shizik_is_not_personally_met_before_boss()
	test_boss_initial_state_and_telegraphs()
	test_acceleration_curve_is_observable_and_deterministic()
	test_boss_defeat_and_mouthpiece_cut_are_idempotent()
	test_level_completion_updates_progress_and_base_presentation()
	return failures

func test_route_requires_order() -> void:
	var flow = DanangFlowScript.new()
	_check(not flow.enter_room(&"club"), "route rejects club before arrival")
	_check(flow.enter_room(&"arrival"), "route enters arrival")
	_check(flow.enter_room(&"backstreet"), "route enters backstreet")
	_check(flow.enter_room(&"entertainment_house"), "route enters entertainment house")
	_check(flow.enter_room(&"syringe_arena"), "route enters syringe arena")
	_check(not flow.enter_room(&"backstreet"), "route cannot go backwards")

func test_shizik_is_not_personally_met_before_boss() -> void:
	var flow = DanangFlowScript.new()
	_check(not flow.shizik_personally_met, "Shizik is not personally met initially")
	flow.enter_room(&"arrival")
	flow.enter_room(&"backstreet")
	flow.enter_room(&"entertainment_house")
	_check(not flow.shizik_personally_met, "pre-boss route cannot meet Shizik personally")
	_check(not flow.rescued_shizik, "Shizik cannot be rescued before boss")

func test_boss_initial_state_and_telegraphs() -> void:
	var boss = SyringeBossScript.new()
	_check(not boss.is_defeated(), "syringe starts undefeated")
	_check(not boss.started, "syringe does not start before start()")
	boss.start()
	_check(boss.started, "syringe start succeeds")
	_check(boss.current_attack == &"", "syringe starts without an active attack")
	_check(boss.attack_telegraph(&"thrust"), "thrust has a readable telegraph")
	_check(boss.telegraph_active, "telegraph is observable")
	_check(boss.telegraph_for(&"thrust") > 0.0, "thrust telegraph has a readable duration")
	_check(not boss.attack_telegraph(&"unknown"), "unknown attack has no telegraph")

func test_acceleration_curve_is_observable_and_deterministic() -> void:
	var first = SyringeBossScript.new()
	first.start()
	var first_curve: Array[float] = []
	for index in range(4):
		first.attack_telegraph(&"thrust")
		first_curve.append(first.current_attack_speed)
		first.advance_attack()
	_check(first_curve[0] < first_curve[1], "attack speed accelerates on second cycle")
	_check(first_curve[1] < first_curve[2], "attack speed accelerates on third cycle")
	_check(first_curve[2] < first_curve[3], "attack speed accelerates on fourth cycle")
	var second = SyringeBossScript.new()
	second.start()
	for index in range(4):
		second.attack_telegraph(&"thrust")
		_check(is_equal_approx(first_curve[index], second.current_attack_speed), "acceleration curve is deterministic")
		second.advance_attack()

func test_boss_defeat_and_mouthpiece_cut_are_idempotent() -> void:
	var boss = SyringeBossScript.new()
	var signal_count: Array[int] = [0]
	boss.defeated.connect(func() -> void: signal_count[0] += 1)
	boss.start()
	for index in range(boss.required_attack_cycles):
		boss.attack_telegraph(&"thrust")
		boss.advance_attack()
	_check(boss.is_defeated(), "syringe is defeated after combat condition")
	_check(boss.defeated_count == 1, "defeated is emitted exactly once")
	_check(signal_count[0] == 1, "defeated signal is observed exactly once")
	_check(boss.cut_into_mouthpiece(), "defeated syringe can become mouthpiece")
	_check(not boss.cut_into_mouthpiece(), "second mouthpiece cut is ignored")
	_check(boss.defeated_count == 1, "mouthpiece cut does not emit defeated again")
	_check(boss.mouthpiece_created, "mouthpiece creation is observable")

func test_level_completion_updates_progress_and_base_presentation() -> void:
	var progress := ProgressState.new()
	progress.collect_artifact(&"cigar_cutter")
	progress.collect_artifact(&"ashtray")
	progress.collect_artifact(&"lighter_heart")
	var flow = DanangFlowScript.new(progress)
	flow.enter_room(&"arrival")
	flow.enter_room(&"backstreet")
	flow.enter_room(&"entertainment_house")
	flow.enter_room(&"syringe_arena")
	var boss = SyringeBossScript.new()
	boss.start()
	for index in range(boss.required_attack_cycles):
		boss.attack_telegraph(&"thrust")
		boss.advance_attack()
	flow.complete_syringe_boss(boss)
	_check(flow.shizik_personally_met, "Shizik is met after boss victory")
	_check(flow.rescued_shizik, "Shizik is rescued after boss victory")
	_check(flow.shizik_arrived_at_base, "Shizik arrives at base")
	_check(flow.unnamed_followers_arrived_at_base, "unnamed followers arrive at base")
	_check(flow.presentation_state == &"remote_safe_entertainment", "remote safe entertainment state is presented")
	flow.complete_level()
	flow.complete_level()
	_check(progress.has_artifact(&"mouthpiece"), "victory grants mouthpiece")
	_check(progress.artifacts.count(&"mouthpiece") == 1, "mouthpiece is granted exactly once")
	_check(flow.current_room == &"base", "completed level transitions to base")
	_check(not progress.has_artifact(&"unrelated_artifact"), "flow does not change unrelated artifacts")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
