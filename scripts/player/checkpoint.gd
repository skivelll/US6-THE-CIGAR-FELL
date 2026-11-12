class_name Checkpoint
extends Area2D

signal activated(pos: Vector2)

var is_active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if is_active:
		return
	if body is PlayerController:
		is_active = true
		body.set_checkpoint(global_position)
		emit_signal("activated", global_position)
