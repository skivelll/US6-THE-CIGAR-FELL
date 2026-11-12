class_name BaseController
extends RefCounted

const BaseStateView = preload("res://scripts/base/base_state_view.gd")

const REQUIRED_ARTIFACTS: Array[StringName] = [&"cigar_cutter", &"ashtray", &"lighter_heart", &"mouthpiece"]

var state_view: BaseStateView = BaseStateView.new()
var progress: ProgressState
var finale_confirmation_required: bool = false
var finale_started: bool = false

func apply_progress(progress_state: ProgressState) -> void:
	progress = progress_state
	state_view.apply_progress(progress_state)
	if finale_started:
		return
	finale_confirmation_required = false

func begin_finale() -> bool:
	if finale_started or progress == null or not _has_all_artifacts():
		return false
	finale_confirmation_required = true
	return false

func confirm_finale() -> bool:
	if not finale_confirmation_required or progress == null or not _has_all_artifacts():
		return false
	finale_confirmation_required = false
	finale_started = true
	return true

func _has_all_artifacts() -> bool:
	for artifact_id: StringName in REQUIRED_ARTIFACTS:
		if not progress.has_artifact(artifact_id):
			return false
	return true
