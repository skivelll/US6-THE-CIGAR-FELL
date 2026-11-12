extends SceneTree

const PlayerStatsScript = preload("res://scripts/player/player_stats.gd")

var failed: int = 0

func _check(desc: String, condition: bool) -> void:
	if condition:
		print("  PASS: ", desc)
	else:
		print("  FAIL: ", desc)
		failed += 1

func _initialize() -> void:
	print("=== US6 Test Suite ===")
	_run_progress_state_tests()
	_run_player_controller_tests()
	_run_player_stats_tests()
	_run_checkpoint_tests()
	print("=== ", ("ALL PASS" if failed == 0 else str(failed) + " FAILED"), " ===")
	quit(1 if failed > 0 else 0)

func _run_progress_state_tests() -> void:
	print("--- ProgressState ---")
	var ps: ProgressState = ProgressState.new()
	_check("starts with no abilities", ps.abilities.is_empty())
	_check("starts with no artifacts", ps.artifacts.is_empty())
	ps.unlock_ability(&"jump_attack")
	_check("unlock ability", ps.has_ability(&"jump_attack"))
	ps.collect_artifact(&"cutter")
	_check("collect artifact", ps.has_artifact(&"cutter"))
	var snap: Dictionary = ps.snapshot()
	_check("snapshot has abilities key", snap.has("abilities"))
	_check("snapshot has artifacts key", snap.has("artifacts"))
	ps.reset()
	_check("reset clears abilities", ps.abilities.is_empty())
	_check("reset clears artifacts", ps.artifacts.is_empty())

func _run_player_controller_tests() -> void:
	print("--- PlayerController ---")
	var p: PlayerController = PlayerController.new()
	p._ready()
	_check("starts at full hp", p.hp == 100)
	p.take_damage(1)
	_check("take_damage reduces hp", p.hp == 99)
	p.is_dodging = true
	p.take_damage(1)
	_check("dodge blocks damage", p.hp == 99)
	p.is_dodging = false
	var died_fired: Array[bool] = [false]
	p.died.connect(func() -> void: died_fired[0] = true)
	p.take_damage(99)
	_check("lethal damage kills", p.is_dead)
	_check("die emits signal", died_fired[0])
	var cp: Vector2 = Vector2(50.0, 50.0)
	p.set_checkpoint(cp)
	p.respawn()
	_check("respawn restores hp", p.hp == 100)
	_check("respawn clears dead flag", not p.is_dead)
	_check("respawn at checkpoint", p.global_position == cp)
	p.free()

func _run_player_stats_tests() -> void:
	print("--- PlayerStats ---")
	var stats: RefCounted = PlayerStatsScript.new()
	_check("stats starts at full hp", stats.hp == 100)
	stats.take_damage(2)
	_check("stats damage reduces hp", stats.hp == 98)
	stats.take_damage(98)
	_check("stats death flag", stats.is_dead)
	stats.set_respawn_position(Vector2(10.0, 20.0))
	var position: Vector2 = stats.respawn()
	_check("stats respawn restores hp", stats.hp == 100)
	_check("stats respawn position", position == Vector2(10.0, 20.0))

func _run_checkpoint_tests() -> void:
	print("--- Checkpoint ---")
	var manager: CheckpointManager = CheckpointManager.new()
	manager.activate(&"yard", Vector2(100.0, 200.0))
	var state: Dictionary = manager.respawn_state()
	_check("checkpoint stores id", state["id"] == "yard")
	_check("checkpoint stores position", state["position"] == Vector2(100.0, 200.0))
	manager.activate(&"roof", Vector2(300.0, 120.0))
	_check("new checkpoint replaces old", manager.get_respawn_position() == Vector2(300.0, 120.0))
	manager.free()
