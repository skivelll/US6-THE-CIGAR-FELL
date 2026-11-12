extends RefCounted

const ProgressState = preload("res://scripts/core/progress_state.gd")
const BaseStateView = preload("res://scripts/base/base_state_view.gd")
const BaseController = preload("res://scripts/base/base_controller.gd")
const SatelliteScreen = preload("res://scripts/ui/satellite_screen.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var state := ProgressState.new()
	var view := BaseStateView.new()

	state.collect_artifact(&"cigar_cutter")
	view.apply_progress(state)
	_expect(view.has_state(&"cutter"), "cigar_cutter must show cutter", failures)
	_expect(view.has_state(&"watchman_house"), "cigar_cutter must show watchman house", failures)

	state.collect_artifact(&"ashtray")
	view.apply_progress(state)
	_expect(view.has_state(&"ashtray"), "ashtray must show ashtray", failures)
	_expect(view.has_state(&"portak_tower"), "ashtray must show Portak tower", failures)

	state.collect_artifact(&"lighter_heart")
	view.apply_progress(state)
	_expect(view.has_state(&"lighter"), "lighter_heart must show lighter", failures)
	_expect(view.has_state(&"lisa_house"), "lighter_heart must show Lisa house", failures)

	state.collect_artifact(&"mouthpiece")
	view.apply_progress(state)
	_expect(view.has_state(&"mouthpiece"), "mouthpiece must show mouthpiece", failures)
	_expect(view.has_state(&"stairs"), "mouthpiece must show stairs", failures)
	_expect(view.has_state(&"shizik_zone"), "mouthpiece must show Shizik zone", failures)

	var state_count := view.visible_states().size()
	view.apply_progress(state)
	_expect(view.visible_states().size() == state_count, "reapplying progress must not duplicate states", failures)

	state.reset()
	view.apply_progress(state)
	_expect(view.visible_states().is_empty(), "view must remove stale states after reset", failures)

	var controller := BaseController.new()
	_expect(not controller.begin_finale(), "finale must reject incomplete artifacts", failures)
	state.collect_artifact(&"cigar_cutter")
	state.collect_artifact(&"ashtray")
	state.collect_artifact(&"lighter_heart")
	controller.apply_progress(state)
	_expect(not controller.begin_finale(), "finale must reject three artifacts", failures)
	state.collect_artifact(&"mouthpiece")
	controller.apply_progress(state)
	_expect(not controller.begin_finale(), "finale must require explicit confirmation", failures)
	_expect(controller.finale_confirmation_required, "finale warning must be recorded", failures)
	_expect(controller.confirm_finale(), "confirmed finale must start with complete artifacts", failures)
	_expect(controller.finale_started, "confirmed finale must mark start", failures)

	var satellite := SatelliteScreen.new()
	_expect(satellite.describe_anomaly(8, 1) == &"strong_mutation", "strong mutation description", failures)
	_expect(satellite.describe_anomaly(2, 8) == &"artifact_candidate", "large weak anomaly description", failures)
	_expect(satellite.describe_anomaly(2, 2) == &"weak_mutation", "weak mutation description", failures)
	return failures

func _expect(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
