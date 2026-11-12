class_name AttackController
extends RefCounted

const STRONG_COOLDOWN: float = 0.75
const MAX_POTION_CHARGES: int = 3

var progress: ProgressState
var strong_cooldown_remaining: float = 0.0
var potion_charges: int = 0
var last_attack: StringName = &""

func _init(progress_state: ProgressState = null) -> void:
	progress = progress_state if progress_state != null else ProgressState.new()

func advance_time(delta: float) -> void:
	strong_cooldown_remaining = maxf(strong_cooldown_remaining - maxf(delta, 0.0), 0.0)

func request(kind: StringName) -> bool:
	match kind:
		&"normal":
			last_attack = kind
			return true
		&"strong":
			if strong_cooldown_remaining > 0.0:
				return false
			strong_cooldown_remaining = STRONG_COOLDOWN
			last_attack = kind
			return true
		&"combo_step":
			if not progress.has_ability(&"combo"):
				return false
			last_attack = kind
			return true
		&"air_strong":
			if not progress.has_ability(&"air_strong"):
				return false
			last_attack = kind
			return true
		&"use_potion":
			if potion_charges <= 0:
				return false
			potion_charges -= 1
			last_attack = kind
			return true
	return false

func set_potion_charges(charges: int) -> void:
	potion_charges = clampi(charges, 0, MAX_POTION_CHARGES)
