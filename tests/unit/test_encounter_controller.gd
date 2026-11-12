extends RefCounted

const EncounterPhaseScript = preload("res://scripts/encounters/encounter_phase.gd")
const EncounterControllerScript = preload("res://scripts/encounters/encounter_controller.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var first = EncounterPhaseScript.new([&"guard"])
	var second = EncounterPhaseScript.new([&"boss"])
	var encounter = EncounterControllerScript.new([first, second])
	var started: Array[int] = []
	var completions: Array[int] = [0]
	encounter.phase_started.connect(func(index: int) -> void: started.append(index))
	encounter.completed.connect(func() -> void: completions[0] += 1)
	encounter.start()
	if encounter.current_phase_index != 0 or started != [0]:
		failures.append("start begins first phase")
	encounter.advance_phase()
	if encounter.current_phase_index != 0:
		failures.append("phase cannot advance while enemies remain")
	encounter.on_enemy_defeated(&"guard")
	if encounter.current_phase_index != 1 or started != [0, 1]:
		failures.append("defeating required enemy advances to next phase")
	encounter.on_enemy_defeated(&"boss")
	encounter.on_enemy_defeated(&"boss")
	if not encounter.is_completed() or completions[0] != 1:
		failures.append("encounter completes once")
	return failures
