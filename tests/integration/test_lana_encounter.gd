extends RefCounted

const LanaEncounterScript = preload("res://scripts/encounters/lana_encounter.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var lana = LanaEncounterScript.new()
	if lana.phase_count != 3 or lana.phase_index != 0:
		failures.append("Lana starts with three songs")
	if lana.has_method("damage") or lana.has_method("take_damage") or "hp" in lana:
		failures.append("Lana has no HP or damage interface")
	lana.start()
	for expected_phase in range(3):
		var expected_mobs: Array[StringName] = [&"kittens"]
		if expected_phase >= 1:
			expected_mobs.append(&"papy_flowers")
		if expected_phase >= 2:
			expected_mobs.append(&"skelberry")
		if lana.wave_composition != expected_mobs:
			failures.append("Lana wave composition expands by song")
		lana.on_wave_cleared()
		if expected_phase < 2:
			if lana.is_completed() or not lana.advance_song():
				failures.append("Lana advances after clearing song wave")
			if lana.arena_revision != expected_phase + 1:
				failures.append("Lana changes arena between songs")
	if not lana.is_completed():
		failures.append("Lana completes after three cleared waves")
	lana.complete()
	if not lana.smoke_returned or not lana.ashtray_ready:
		failures.append("Lana returns tattoos and readies ashtray")
	if lana.advance_song():
		failures.append("completed Lana cannot advance again")
	return failures
