class_name PerformanceProbe
extends RefCounted

const FRAME_TIME_BUDGET_MS: float = 33.34
const PEAK_ENEMIES_BUDGET: int = 32
const PEAK_PARTICLES_BUDGET: int = 400
const DRAW_CALL_BUDGET: int = 250

var sampler: Callable

func sample(duration_seconds: float) -> Dictionary:
	var duration: float = maxf(duration_seconds, 0.0)
	var measured: Dictionary = {}
	if sampler.is_valid():
		measured = sampler.call(duration)
	else:
		measured = {
			"average_frame_time_ms": 0.0,
			"peak_frame_time_ms": 0.0,
			"peak_active_enemies": 0,
			"peak_particles": 0,
			"draw_calls": 0,
		}
	var result := {
		"duration_seconds": duration,
		"average_frame_time_ms": float(measured.get("average_frame_time_ms", 0.0)),
		"peak_frame_time_ms": float(measured.get("peak_frame_time_ms", 0.0)),
		"peak_active_enemies": int(measured.get("peak_active_enemies", 0)),
		"peak_particles": int(measured.get("peak_particles", 0)),
		"draw_calls": int(measured.get("draw_calls", 0)),
	}
	result["within_budget"] = result.peak_frame_time_ms <= FRAME_TIME_BUDGET_MS \
		and result.peak_active_enemies <= PEAK_ENEMIES_BUDGET \
		and result.peak_particles <= PEAK_PARTICLES_BUDGET \
		and result.draw_calls <= DRAW_CALL_BUDGET
	return result
