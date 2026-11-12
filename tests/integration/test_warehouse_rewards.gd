extends RefCounted

const ProgressStateScript = preload("res://scripts/core/progress_state.gd")
const WarehouseFlowScript = preload("res://scripts/levels/warehouse_flow.gd")
const KittenHydraScript = preload("res://scripts/encounters/kitten_hydra.gd")
const PapyFlowersScript = preload("res://scripts/encounters/papy_flowers.gd")
const SkelberryScript = preload("res://scripts/encounters/skelberry.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	var progress = ProgressStateScript.new()
	var flow = WarehouseFlowScript.new(progress)
	if flow.current_room != &"warehouse_exterior":
		failures.append("warehouse starts outside")
	var kittens = KittenHydraScript.new()
	var kitten_rewards: Array[StringName] = []
	kittens.reward_granted.connect(func(id: StringName) -> void: kitten_rewards.append(id))
	kittens.defeat_head(0)
	kittens.defeat_head(0)
	if kittens.heads_returned != 1:
		failures.append("kitten head cannot be defeated twice")
	for head in range(1, 4):
		kittens.defeat_head(head)
	if kitten_rewards != [&"kittens"]:
		failures.append("kitten hydra grants one reward after four heads")
	flow.complete_kittens(kittens)
	if not progress.has_ability(&"combo"):
		failures.append("kittens unlock combo")
	var papy = PapyFlowersScript.new()
	var papy_rewards: Array[StringName] = []
	papy.reward_granted.connect(func(id: StringName) -> void: papy_rewards.append(id))
	papy.defeat()
	flow.complete_papy_flowers(papy)
	if papy_rewards != [&"papy_flowers"] or not progress.has_ability(&"air_strong"):
		failures.append("Papy Flowers unlocks air strong")
	var skelberry = SkelberryScript.new()
	var skel_rewards: Array[StringName] = []
	skelberry.reward_granted.connect(func(id: StringName) -> void: skel_rewards.append(id))
	skelberry.defeat()
	flow.complete_skelberry(skelberry)
	if skel_rewards != [&"skelberry"] or not progress.has_ability(&"use_potion"):
		failures.append("Skelberry unlocks potion")
	if not flow.portak_rescued:
		failures.append("warehouse flow rescues Portak")
	flow.complete_level()
	if not progress.has_artifact(&"ashtray") or flow.current_room != &"base":
		failures.append("warehouse completion grants ashtray and returns to base")
	flow.complete_level()
	if progress.artifacts.count(&"ashtray") != 1:
		failures.append("ashtray is collected only once")
	return failures
