class_name TutorialPrompt
extends Label

var action_id: StringName = &""
var dismissed: bool = false

func show_action_prompt(id: StringName, text: String) -> void:
	action_id = id
	text = text
	visible = true
	dismissed = false

func dismiss() -> void:
	dismissed = true
	visible = false
