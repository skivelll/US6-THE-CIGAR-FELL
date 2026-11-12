class_name Checkpoint
extends Area2D

@export var checkpoint_id: StringName = &"checkpoint"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	CheckpointManagerSingleton.register_checkpoint(checkpoint_id, global_position)

func _on_body_entered(body: Node2D) -> void:
	var player: PlayerController = body as PlayerController
	if player == null:
		return
	CheckpointManagerSingleton.activate_checkpoint(checkpoint_id)
	player.set_checkpoint(global_position)
