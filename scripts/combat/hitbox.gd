class_name Hitbox
extends RefCounted

var owner_id: StringName = &""
var damage_amount: int = 1

func _init(owner: StringName = &"", amount: int = 1) -> void:
	owner_id = owner
	damage_amount = maxi(amount, 0)

func hit(target: HealthComponent) -> int:
	if target == null:
		return 0
	return target.damage(damage_amount, owner_id)
