extends RefCounted

const ProgressStateScript = preload("res://scripts/core/progress_state.gd")
const AttackControllerScript = preload("res://scripts/combat/attack_controller.gd")
const HealthComponentScript = preload("res://scripts/combat/health_component.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var progress: ProgressState = ProgressStateScript.new()
	var attacks = AttackControllerScript.new(progress)
	if not attacks.request(&"normal"):
		failures.append("normal attack is available")
	if not attacks.request(&"strong"):
		failures.append("strong attack is initially available")
	if attacks.request(&"strong"):
		failures.append("strong attack respects cooldown")
	attacks.advance_time(1.0)
	if not attacks.request(&"strong"):
		failures.append("strong attack becomes available after cooldown")
	if attacks.request(&"combo_step"):
		failures.append("combo is locked before kittens")
	progress.unlock_ability(&"combo")
	if not attacks.request(&"combo_step"):
		failures.append("combo unlocks from progress")
	if not attacks.request(&"combo_step"):
		failures.append("combo allows its third step")
	if not attacks.request(&"combo_step"):
		failures.append("combo allows its final step")
	if attacks.request(&"combo_step"):
		failures.append("combo stops after three steps")
	if attacks.request(&"air_strong"):
		failures.append("air strong is locked before Papy Flowers")
	progress.unlock_ability(&"air_strong")
	if not attacks.request(&"air_strong"):
		failures.append("air strong unlocks from progress")
	attacks.set_potion_charges(2)
	if not attacks.request(&"use_potion") or attacks.potion_charges != 1:
		failures.append("potion consumes one bounded charge")
	attacks.set_potion_charges(99)
	if attacks.potion_charges != attacks.MAX_POTION_CHARGES:
		failures.append("potion charges are bounded")
	var health = HealthComponentScript.new(10, &"player")
	if health.damage(3, &"enemy") != 3 or health.current_hp != 7:
		failures.append("health damage reduces HP")
	if health.damage(3, health.owner_id) != 0:
		failures.append("health rejects damage from its owner")
	health.damage(7, &"enemy")
	if not health.is_defeated():
		failures.append("health reports defeat at zero")
	return failures
