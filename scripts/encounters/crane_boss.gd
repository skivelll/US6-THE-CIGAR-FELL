class_name CraneBoss
extends RefCounted

var phase_index: int = -1
var _phase_one_targets: Array[StringName] = [&"summoned_mob", &"shadow_hook"]
var _phase_one_defeated: Array[StringName] = []
var _phase_two_attacks: Array[StringName] = [&"top_attack", &"bottom_attack"]
var _phase_two_telegraphed: Array[StringName] = []
var _completed: bool = false

func start() -> void:
	if phase_index == -1:
		phase_index = 0

func on_enemy_defeated(enemy_id: StringName) -> void:
	if phase_index != 0 or _phase_one_defeated.has(enemy_id):
		return
	if _phase_one_targets.has(enemy_id):
		_phase_one_defeated.append(enemy_id)
	if _phase_one_defeated.size() == _phase_one_targets.size():
		phase_index = 1

func on_attack_telegraph_completed(attack_id: StringName) -> void:
	if phase_index != 1 or _phase_two_telegraphed.has(attack_id):
		return
	if _phase_two_attacks.has(attack_id):
		_phase_two_telegraphed.append(attack_id)
	if _phase_two_telegraphed.size() == _phase_two_attacks.size():
		_completed = true

func is_completed() -> bool:
	return _completed
