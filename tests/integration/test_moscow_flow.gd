extends RefCounted

const ProgressStateScript = preload("res://scripts/core/progress_state.gd")
const MoscowFlowScript = preload("res://scripts/levels/moscow_flow.gd")
const CraneBossScript = preload("res://scripts/encounters/crane_boss.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var progress = ProgressStateScript.new()
	var flow = MoscowFlowScript.new(progress)
	if flow.current_room != &"lightroom":
		failures.append("Moscow starts in Lightroom")
	if progress.has_ability(&"combat"):
		failures.append("combat starts locked before the coal sword")
	flow.create_coal_sword()
	if not progress.has_ability(&"combat") or not progress.has_ability(&"normal_attack"):
		failures.append("coal sword unlocks the basic combat kit")
	for room in [&"rolex", &"nikolskaya", &"construction"]:
		if not flow.enter_room(room):
			failures.append("Moscow route accepts room " + String(room))
	if flow.enter_room(&"wrong_room"):
		failures.append("Moscow route rejects rooms out of order")
	var boss = CraneBossScript.new()
	boss.start()
	boss.on_enemy_defeated(&"summoned_mob")
	if boss.phase_index != 0:
		failures.append("crane phase one waits for all summoned mobs")
	boss.on_enemy_defeated(&"shadow_hook")
	if boss.phase_index != 1:
		failures.append("crane advances to phase two after phase one")
	boss.on_attack_telegraph_completed(&"top_attack")
	if boss.is_completed():
		failures.append("crane phase two waits for its attack condition")
	boss.on_attack_telegraph_completed(&"bottom_attack")
	if not boss.is_completed():
		failures.append("crane completes after phase two attacks")
	flow.complete_level()
	if not progress.has_artifact(&"cigar_cutter"):
		failures.append("Moscow completion grants exactly the cigar cutter")
	if flow.current_room != &"base":
		failures.append("Moscow completion returns to base")
	flow.complete_level()
	if progress.artifacts.count(&"cigar_cutter") != 1:
		failures.append("cigar cutter is collected only once")
	return failures
