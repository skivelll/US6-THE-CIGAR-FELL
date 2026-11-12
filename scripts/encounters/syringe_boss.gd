class_name SyringeBoss
extends Node2D

signal defeated

const ATTACK_TELEGRAPHS: Dictionary = {
	&"thrust": 0.65,
	&"top_drop": 0.8,
	&"bottom_sweep": 0.75,
	&"summon": 1.0,
}
const BASE_ATTACK_SPEED := 1.0
const ACCELERATION_PER_CYCLE := 0.18

var required_attack_cycles: int = 4
var current_attack: StringName = &""
var current_attack_speed: float = BASE_ATTACK_SPEED
var telegraph_active := false
var started := false
var mouthpiece_created := false
var _attack_cycles := 0
var _defeated := false
var _defeated_emitted := false
var defeated_count := 0

func start() -> void:
	if not _defeated:
		started = true

func attack_telegraph(attack_id: StringName) -> bool:
	if not started or _defeated or not ATTACK_TELEGRAPHS.has(attack_id):
		return false
	current_attack = attack_id
	current_attack_speed = BASE_ATTACK_SPEED + ACCELERATION_PER_CYCLE * _attack_cycles
	telegraph_active = true
	return true

func telegraph_for(attack_id: StringName) -> float:
	return float(ATTACK_TELEGRAPHS.get(attack_id, 0.0))

func advance_attack() -> bool:
	if not started or _defeated or not telegraph_active:
		return false
	telegraph_active = false
	_attack_cycles += 1
	if _attack_cycles >= required_attack_cycles:
		_defeated = true
		if not _defeated_emitted:
			_defeated_emitted = true
			defeated_count += 1
			defeated.emit()
	return true

func cut_into_mouthpiece() -> bool:
	if not _defeated or mouthpiece_created:
		return false
	mouthpiece_created = true
	return true

func is_defeated() -> bool:
	return _defeated
