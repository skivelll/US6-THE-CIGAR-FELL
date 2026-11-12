class_name PapyFlowers
extends RefCounted

signal reward_granted(id: StringName)
var _defeated: bool = false
var _rewarded: bool = false

func defeat() -> void:
	if _defeated:
		return
	_defeated = true
	if not _rewarded:
		_rewarded = true
		reward_granted.emit(&"papy_flowers")

func is_defeated() -> bool:
	return _defeated
