extends SceneTree

func _initialize() -> void:
	var danang := load("res://scenes/levels/danang.tscn") as PackedScene
	var boss := load("res://scenes/encounters/syringe_boss.tscn") as PackedScene
	if danang == null or boss == null:
		push_error("Danang scene smoke-load failed")
		quit(1)
		return
	var danang_instance := danang.instantiate()
	var boss_instance := boss.instantiate()
	root.add_child(danang_instance)
	root.add_child(boss_instance)
	if danang_instance.get_node_or_null("BossArena") == null or boss_instance.get_node_or_null("Telegraph") == null:
		push_error("Danang scene contract nodes missing")
		quit(1)
		return
	danang_instance.queue_free()
	boss_instance.queue_free()
	print("DANANG SCENE SMOKE PASS")
	quit(0)
