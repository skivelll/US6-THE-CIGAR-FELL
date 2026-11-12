extends RefCounted

const PlayerStats = preload("res://scripts/player/player_stats.gd")
const ProgressState = preload("res://scripts/core/progress_state.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var stats: PlayerStats = PlayerStats.new()
	if stats.hp != PlayerStats.MAX_HP:
		failures.append("player starts with three health")
	stats.take_damage(1)
	if stats.hp != 2:
		failures.append("damage reduces health")
	stats.take_damage(99)
	if not stats.is_dead or stats.hp != 0:
		failures.append("lethal damage marks player dead")
	var progress: ProgressState = ProgressState.new()
	progress.unlock_ability(&"air_dash")
	stats.progress_state = progress
	stats.set_respawn_position(Vector2(40.0, 80.0))
	var respawn_position: Vector2 = stats.respawn()
	if stats.is_dead or stats.hp != PlayerStats.MAX_HP:
		failures.append("respawn restores health and alive state")
	if respawn_position != Vector2(40.0, 80.0):
		failures.append("respawn returns checkpoint position")
	if not stats.progress_state.has_ability(&"air_dash"):
		failures.append("respawn preserves unlocked abilities")
	return failures
