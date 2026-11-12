class_name HealthComponent
extends RefCounted

signal damaged(amount: int, source: StringName)
signal defeated(source: StringName)

var max_hp: int
var current_hp: int
var owner_id: StringName = &""
var _defeated: bool = false

func _init(maximum_hp: int = 1, owner: StringName = &"") -> void:
	max_hp = maxi(maximum_hp, 1)
	current_hp = max_hp
	owner_id = owner

func damage(amount: int, source: StringName = &"") -> int:
	if _defeated or amount <= 0 or (owner_id != &"" and source == owner_id):
		return 0
	var applied: int = mini(amount, current_hp)
	current_hp -= applied
	damaged.emit(applied, source)
	if current_hp == 0:
		_defeated = true
		defeated.emit(source)
	return applied

func is_defeated() -> bool:
	return _defeated

func restore() -> void:
	current_hp = max_hp
	_defeated = false
