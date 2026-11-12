extends RefCounted

const PlayerController = preload("res://scripts/core/player_controller.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var player = PlayerController.new()
	player._ready()
	if player.hp != 5:
		failures.append("player starts with full HP")
	player.take_damage(2)
	if player.hp != 3:
		failures.append("take_damage reduces HP to 3")
	var died_emitted: Array[bool] = [false]
	player.died.connect(func() -> void: died_emitted[0] = true)
	player.take_damage(10)
	if player.hp != 0 or not died_emitted[0]:
		failures.append("lethal damage sets HP to zero and emits died")
	if player._get_respawn_position() != Vector2(100.0, 300.0):
		failures.append("default respawn position comes from checkpoint manager")
	player.free()
	return failures
