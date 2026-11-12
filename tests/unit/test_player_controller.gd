extends SceneTree

var failed: int = 0

func _check(desc: String, condition: bool) -> void:
	if condition:
		print("  PASS: ", desc)
	else:
		print("  FAIL: ", desc)
		failed += 1

func _initialize() -> void:
	print("--- PlayerController tests ---")
	_test_take_damage()
	_test_dodge_invincibility()
	_test_checkpoint()
	_test_die_and_respawn()
	print("--- done: ", ("PASS" if failed == 0 else str(failed) + " FAILED"), " ---")
	quit(1 if failed > 0 else 0)

func _test_take_damage() -> void:
	var p := PlayerController.new()
	p.hp = 3
	p.take_damage(1)
	_check("take_damage reduces hp", p.hp == 2)
	p.free()

func _test_dodge_invincibility() -> void:
	var p := PlayerController.new()
	p.hp = 3
	p.is_dodging = true
	p.take_damage(1)
	_check("dodge blocks damage", p.hp == 3)
	p.free()

func _test_checkpoint() -> void:
	var p := PlayerController.new()
	var pos := Vector2(300.0, 200.0)
	p.set_checkpoint(pos)
	_check("checkpoint stored", p.checkpoint_position == pos)
	p.free()

func _test_die_and_respawn() -> void:
	var p := PlayerController.new()
	p.hp = 1
	var died_signal := false
	p.died.connect(func(): died_signal = true)
	p.take_damage(1)
	_check("die emits signal", died_signal)
	_check("is_dead set", p.is_dead)
	p.set_checkpoint(Vector2(100.0, 100.0))
	p.respawn()
	_check("respawn restores hp", p.hp == PlayerController.MAX_HP)
	_check("respawn clears is_dead", not p.is_dead)
	_check("respawn moves to checkpoint", p.global_position == Vector2(100.0, 100.0))
	p.free()
