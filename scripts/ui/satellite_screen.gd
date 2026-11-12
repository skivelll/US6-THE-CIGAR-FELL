class_name SatelliteScreen
extends RefCounted

const STRONG_MUTATION_THRESHOLD: int = 7
const LARGE_OBJECT_THRESHOLD: int = 6

func describe_anomaly(mutation_strength: int, object_size: int) -> StringName:
	if mutation_strength >= STRONG_MUTATION_THRESHOLD:
		return &"strong_mutation"
	if object_size >= LARGE_OBJECT_THRESHOLD:
		return &"artifact_candidate"
	return &"weak_mutation"
