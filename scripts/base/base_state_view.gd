class_name BaseStateView
extends RefCounted

const ARTIFACT_STATES: Dictionary = {
	&"cigar_cutter": [&"cutter", &"watchman_house"],
	&"ashtray": [&"ashtray", &"portak_tower"],
	&"lighter_heart": [&"lighter", &"lisa_house"],
	&"mouthpiece": [&"mouthpiece", &"stairs", &"shizik_zone"],
}

var _visible_states: Array[StringName] = []

func apply_progress(progress: ProgressState) -> void:
	_visible_states.clear()
	for artifact_id: StringName in ARTIFACT_STATES.keys():
		if progress.has_artifact(artifact_id):
			for state_id: StringName in ARTIFACT_STATES[artifact_id]:
				_visible_states.append(state_id)

func has_state(id: StringName) -> bool:
	return _visible_states.has(id)

func visible_states() -> Array[StringName]:
	return _visible_states.duplicate()
