class_name Hurtbox
extends RefCounted

var health: HealthComponent

func _init(health_component: HealthComponent = null) -> void:
	health = health_component

func receive_hit(hitbox: Hitbox) -> int:
	if hitbox == null or health == null:
		return 0
	return hitbox.hit(health)
