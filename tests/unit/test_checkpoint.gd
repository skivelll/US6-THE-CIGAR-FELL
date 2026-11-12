extends RefCounted

const CheckpointManager = preload("res://scripts/core/checkpoint_manager.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var manager: CheckpointManager = CheckpointManager.new()
	manager.activate(&"yard", Vector2(120.0, 240.0), 3, 1)
	var state: Dictionary = manager.respawn_state()
	if state["id"] != "yard":
		failures.append("checkpoint stores its id")
	if state["position"] != Vector2(120.0, 240.0):
		failures.append("checkpoint stores respawn position")
	manager.activate(&"rooftop", Vector2(300.0, 100.0))
	if manager.get_respawn_position() != Vector2(300.0, 100.0):
		failures.append("new checkpoint replaces previous checkpoint")
	manager.free()
	return failures
