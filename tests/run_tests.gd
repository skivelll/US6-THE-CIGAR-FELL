extends SceneTree

const ProgressStateTests = preload("res://tests/unit/test_progress_state.gd")
const PlayerTests = preload("res://tests/unit/test_player.gd")
const CheckpointTests = preload("res://tests/unit/test_checkpoint_manager.gd")
const CombatTests = preload("res://tests/unit/test_combat_kernel.gd")
const EncounterTests = preload("res://tests/unit/test_encounter_controller.gd")
const MoscowTests = preload("res://tests/integration/test_moscow_flow.gd")
const WarehouseTests = preload("res://tests/integration/test_warehouse_rewards.gd")
const LanaTests = preload("res://tests/integration/test_lana_encounter.gd")
const BaseTests = preload("res://tests/unit/test_base_state_view.gd")
const RyazanTests = preload("res://tests/integration/test_ryazan_flow.gd")

var failures: Array[String] = []

func _initialize() -> void:
	_run_test("ProgressState", ProgressStateTests.new())
	_run_test("Player", PlayerTests.new())
	_run_test("CheckpointManager", CheckpointTests.new())
	_run_test("CombatKernel", CombatTests.new())
	_run_test("EncounterController", EncounterTests.new())
	_run_test("MoscowFlow", MoscowTests.new())
	_run_test("WarehouseRewards", WarehouseTests.new())
	_run_test("LanaEncounter", LanaTests.new())
	_run_test("BaseState", BaseTests.new())
	_run_test("RyazanFlow", RyazanTests.new())
	if failures.is_empty():
		print("=== ALL PASS ===")
		quit(0)
	else:
		for failure: String in failures:
			print("FAIL: ", failure)
		print("=== ", failures.size(), " FAILED ===")
		quit(1)

func _run_test(name: String, test: RefCounted) -> void:
	print("--- ", name, " ---")
	var test_failures: Array[String] = test.run()
	if test_failures.is_empty():
		print("PASS")
	else:
		for failure: String in test_failures:
			failures.append(name + ": " + failure)
