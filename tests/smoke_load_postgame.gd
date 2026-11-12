extends SceneTree

func _initialize() -> void:
	var epilogue: PackedScene = load("res://scenes/epilogue/epilogue.tscn")
	var memory_menu: PackedScene = load("res://scenes/ui/memory_menu.tscn")
	if epilogue == null or memory_menu == null:
		push_error("postgame scene smoke-load failed")
		quit(1)
		return
	var probe_script = load("res://scripts/platform/performance_probe.gd")
	var probe = probe_script.new()
	var result: Dictionary = probe.sample(0.1)
	if not result.has("within_budget"):
		push_error("performance probe smoke-load failed")
		quit(1)
		return
	print("POSTGAME SCENES PASS")
	print("PERFORMANCE PROBE: ", result)
	quit(0)
