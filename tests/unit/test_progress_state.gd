extends RefCounted

const ProgressState = preload("res://scripts/core/progress_state.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var state = ProgressState.new()

	var fresh_snapshot: Dictionary = state.snapshot()
	if not fresh_snapshot.has("abilities") or not fresh_snapshot.has("artifacts"):
		failures.append("fresh snapshot must expose progress collections")
	if not (fresh_snapshot["abilities"] as Array).is_empty() or not (fresh_snapshot["artifacts"] as Array).is_empty():
		failures.append("fresh progress collections must be empty")
	state.unlock_ability(&"combo")
	state.unlock_ability(&"combo")
	if not state.has_ability(&"combo"):
		failures.append("unlocked ability must be available")
	if state.snapshot()["abilities"].size() != 1:
		failures.append("ability unlock must be idempotent")
	state.collect_artifact(&"cigar_cutter")
	state.collect_artifact(&"cigar_cutter")
	if not state.has_artifact(&"cigar_cutter"):
		failures.append("collected artifact must be available")
	if state.snapshot()["artifacts"].size() != 1:
		failures.append("artifact collection must be idempotent")

	var snapshot: Dictionary = state.snapshot()
	if typeof(snapshot["abilities"]) != TYPE_ARRAY or typeof(snapshot["artifacts"]) != TYPE_ARRAY:
		failures.append("snapshot collections must be arrays")
	for value in snapshot["abilities"] + snapshot["artifacts"]:
		if typeof(value) != TYPE_STRING:
			failures.append("snapshot values must be primitive strings")
	state.reset()
	var reset_snapshot: Dictionary = state.snapshot()
	if not (reset_snapshot["abilities"] as Array).is_empty() or not (reset_snapshot["artifacts"] as Array).is_empty():
		failures.append("reset must clear progress")
	return failures
