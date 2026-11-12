extends SceneTree

const TESTS: Array[Script] = [preload("res://tests/unit/test_progress_state.gd")]

func _initialize() -> void:
	var failures: Array[String] = []
	for test_script: Script in TESTS:
		var test = test_script.new()
		failures.append_array(test.run())
	if failures.is_empty():
		print("PASS: %d test suite(s)" % TESTS.size())
	else:
		for failure: String in failures:
			push_error("FAIL: " + failure)
		print("FAILED: %d assertion(s)" % failures.size())
	quit(1 if not failures.is_empty() else 0)
