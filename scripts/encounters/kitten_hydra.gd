class_name KittenHydra
extends RefCounted

signal reward_granted(id: StringName)

const HEAD_COUNT: int = 4
var heads_returned: int = 0
var _defeated_heads: Array[int] = []
var _rewarded: bool = false

func defeat_head(head_index: int) -> void:
	if head_index < 0 or head_index >= HEAD_COUNT or _defeated_heads.has(head_index):
		return
	_defeated_heads.append(head_index)
	heads_returned = _defeated_heads.size()
	if heads_returned == HEAD_COUNT and not _rewarded:
		_rewarded = true
		reward_granted.emit(&"kittens")

func is_defeated() -> bool:
	return heads_returned == HEAD_COUNT
