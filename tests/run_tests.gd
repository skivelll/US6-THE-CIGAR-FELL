extends SceneTree

const ProgressStateTests = preload("res://tests/unit/test_progress_state.gd")
const PlayerTests = preload("res://tests/unit/test_player.gd")
const CheckpointTests = preload("res://tests/unit/test_checkpoint_manager.gd")
const CombatTests = preload("res://tests/unit/test_combat_kernel.gd")
const EncounterTests = preload("res://tests/unit/test_encounter_controller.gd")

var failures: Array[String] = []

func _initialize() -> void:
	_run_test("ProgressState", ProgressStateTests.new())
	_run_test("Player", PlayerTests.new())
	_run_test("CheckpointManager", CheckpointTests.new())
	_run_test("CombatKernel", CombatTests.new())
	_run_test("EncounterController", EncounterTests.new())
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
