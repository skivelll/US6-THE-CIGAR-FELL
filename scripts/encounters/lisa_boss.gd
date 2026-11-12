class_name LisaBoss
extends Node2D

const phase_lisa: StringName = &"phase_lisa"
const phase_system: StringName = &"phase_system"

var current_phase: StringName = phase_lisa
var phases: Array[StringName] = [phase_lisa, phase_system]
var second_phase_roster: Array[StringName] = [&"watermelon_ketchup_system"]
var _defeated := false

func break_crown() -> bool:
	if current_phase != phase_lisa:
		return false
	current_phase = phase_system
	return true

func complete_system_phase() -> bool:
	if current_phase != phase_system or _defeated:
		return false
	_defeated = true
	return true

func is_defeated() -> bool:
	return _defeated
