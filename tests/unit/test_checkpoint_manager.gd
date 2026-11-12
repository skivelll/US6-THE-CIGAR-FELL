extends RefCounted

const CheckpointManager = preload("res://scripts/core/checkpoint_manager.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var manager: CheckpointManager = CheckpointManager.new()
	if manager.get_respawn_position() != Vector2(100.0, 300.0):
		failures.append("default respawn position")
	manager.register_checkpoint(&"yard", Vector2(400.0, 220.0))
	manager.activate_checkpoint(&"yard")
	if manager.get_respawn_position() != Vector2(400.0, 220.0):
		failures.append("activated checkpoint changes respawn position")
	manager.reset()
	if manager.get_respawn_position() != Vector2(100.0, 300.0):
		failures.append("reset returns to default respawn position")
	manager.free()
	return failures
