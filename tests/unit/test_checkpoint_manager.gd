extends RefCounted

const CheckpointManager = preload("res://scripts/core/checkpoint_manager.gd")
const ProgressState = preload("res://scripts/core/progress_state.gd")
const PlayerController = preload("res://scripts/player/player_controller.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var checkpoint := CheckpointManager.new()
	checkpoint.activate(&"moscow_01", Vector2(120, 240), 75, 2)
	var state: Dictionary = checkpoint.respawn_state()
	if state["id"] != "moscow_01":
		failures.append("checkpoint stores id")
	if state["position"] != Vector2(120, 240):
		failures.append("checkpoint stores spawn position")
	if state["health"] != 75 or state["potion_charges"] != 2:
		failures.append("checkpoint stores recovery values")
	checkpoint.activate(&"moscow_02", Vector2(400, 180))
	if checkpoint.respawn_state()["id"] != "moscow_02":
		failures.append("new checkpoint replaces old checkpoint")

	var progress := ProgressState.new()
	var player := PlayerController.new()
	player.configure(progress)
	if player.use_ability(&"combo"):
		failures.append("locked ability must be refused")
	progress.unlock_ability(&"combo")
	if not player.use_ability(&"combo"):
		failures.append("unlocked ability must be usable")
	return failures
