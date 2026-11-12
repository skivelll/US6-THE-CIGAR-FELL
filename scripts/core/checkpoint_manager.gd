class_name CheckpointManager
extends Node

var has_checkpoint: bool = false
var active_checkpoint_id: StringName = &""
var active_position: Vector2 = Vector2.ZERO
var active_health: int = 100
var active_potion_charges: int = 0

func activate(checkpoint_id: StringName, spawn_position: Vector2, health: int = 100, potion_charges: int = 0) -> void:
	has_checkpoint = true
	active_checkpoint_id = checkpoint_id
	active_position = spawn_position
	active_health = health
	active_potion_charges = potion_charges

func activate_checkpoint(checkpoint_id: StringName, position: Vector2) -> void:
	activate(checkpoint_id, position)

func get_respawn_position() -> Vector2:
	return active_position

func respawn_state() -> Dictionary:
	return {
		"id": String(active_checkpoint_id),
		"position": active_position,
		"health": active_health,
		"potion_charges": active_potion_charges,
	}

func reset() -> void:
	has_checkpoint = false
	active_checkpoint_id = &""
	active_position = Vector2.ZERO
	active_health = 100
	active_potion_charges = 0
