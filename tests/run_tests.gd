extends SceneTree

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
	print("=== ", ("ALL PASS" if failed == 0 else str(failed) + " FAILED"), " ===")
	quit(1 if failed > 0 else 0)

func _run_progress_state_tests() -> void:
	print("--- ProgressState ---")
	var ps := ProgressState.new()
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
	var p := PlayerController.new()
	_check("starts at full hp", p.hp == PlayerController.MAX_HP)
	p.take_damage(1)
	_check("take_damage reduces hp", p.hp == PlayerController.MAX_HP - 1)
	p.is_dodging = true
	p.take_damage(1)
	_check("dodge blocks damage", p.hp == PlayerController.MAX_HP - 1)
	p.is_dodging = false
	var died_fired: Array[bool] = [false]
	p.died.connect(func(): died_fired[0] = true)
	p.take_damage(99)
	_check("lethal damage kills", p.is_dead)
	_check("die emits signal", died_fired[0])
	var cp := Vector2(50.0, 50.0)
	p.set_checkpoint(cp)
	p.respawn()
	_check("respawn restores hp", p.hp == PlayerController.MAX_HP)
	_check("respawn clears dead flag", not p.is_dead)
	_check("respawn at checkpoint", p.global_position == cp)
	p.free()
