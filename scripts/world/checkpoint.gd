class_name Checkpoint
extends Area2D

@export var checkpoint_id: StringName = &"checkpoint"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var player: PlayerController = body as PlayerController
	if player == null:
		return
	CheckpointManager.activate_checkpoint(checkpoint_id, global_position)
	player.set_checkpoint(global_position)
