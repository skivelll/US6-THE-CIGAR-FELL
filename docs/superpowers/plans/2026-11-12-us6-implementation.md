# US6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** За два месяца собрать законченную 2D-игру-подарок US6 с четырьмя линейными территориями, единым боевым ядром, базой, финалом, эпилогом и личным видеопосланием; первое прохождение должно длиться не меньше трёх часов.

**Architecture:** Godot-проект строится вокруг одного `ProgressState`, одного контроллера Юли и переиспользуемых компонентов столкновений, атак, checkpoint-ов и фазовых encounter-ов. Уровни остаются отдельными сценами, но получают награды и меняют базу через типизированный контракт, а не через прямые ссылки между всеми персонажами. Сначала создаётся полностью играемый вертикальный срез Москвы; остальные территории добавляются только после того, как срез проходит headless-проверки и ручной тест на целевом устройстве.

**Tech Stack:** Godot 4.7, GDScript 2.0, 2D-сцены и `CharacterBody2D`; headless-тесты через `godot --headless`; ввод через InputMap; первоначальная проверка на desktop keyboard/gamepad, затем проверка производительности на выбранной портативной платформе стоимостью до 10 000 ₽.

**Spec:** `docs/superpowers/specs/2026-11-12-us6-master-design.md`

## Global Constraints

- Рабочий формат — **2D**; переход в 3D не является планом по умолчанию.
- Первое прохождение должно длиться **не меньше 3 часов**.
- Разработка ограничена **двумя месяцами** и возможностями целевой портативной платформы стоимостью до 10 000 ₽.
- Постоянное управление не должно разрастаться; новые возможности используют существующие кнопки и действия.
- База развивается автоматически, без ручного строительства и менеджмента.
- Татуировки не становятся отдельным инвентарём, панелью оружия или деревом навыков.
- Порядок территорий: **Центр Москвы → склад в Подмосковье → Рязань → Дананг → база и финал**.
- До угольного меча Юля не наносит урон; после получения меча сохраняются обычная атака и сильная атака с cooldown.
- После котят открывается комбо до трёх ударов; после Papy Flowers — воздушная сильная атака; после Skelberry — зелье здоровья.
- Смотритель, Кирилл Портак и Санбой не должны перетянуть роль главной героини на себя.
- Если масштаб превышен, первыми сокращаются вторичные диалоги, переходные сцены, декоративные интеракции и дополнительные боевые варианты — не ключевые персонажи, территории, артефакты, финал или видеопослание.

## Review Focus

1. **Потеря прогресса после смерти:** Юля возвращается к ближайшему checkpoint с сохранённой наградой и без отката уже открытых возможностей — тест `test_death_restores_checkpoint_without_losing_progress` в Task 2.
2. **Непонятное управление для нулевого игрока:** каждая новая возможность вводится в безопасной ситуации и использует уже известную кнопку — тест `test_new_ability_is_taught_before_required_use` в Task 2.
3. **Пересечение фаз босса и уязвимостей:** фаза завершается только по своему условию, а Lana не получает урон и не имеет HP — тесты `test_lana_phase_ends_after_wave_clear` и `test_lana_has_no_damage_path` в Task 5.
4. **Сломанная последовательность наград и базы:** нельзя попасть в финал без четырёх артефактов, а визуальное состояние базы совпадает с прогрессом — тест `test_base_state_matches_collected_artifacts` в Task 8.
5. **Непроизводительный полный контент на портативной платформе:** в сцене нет бесконтрольного роста врагов, частиц и draw calls; тест `test_target_scene_stays_within_budget` и ручной 10-минутный прогон в Task 10.

---

### Task 1: Project foundation and headless test harness

**Files:**
- Create: `project.godot`
- Create: `scenes/main/main.tscn`
- Create: `scripts/core/game_boot.gd`
- Create: `scripts/core/progress_state.gd`
- Create: `tests/run_tests.gd`
- Create: `tests/unit/test_progress_state.gd`
- Create: `README.md`

**Interfaces:**
- Produces `ProgressState.reset()`, `ProgressState.unlock_ability(id: StringName)`, `ProgressState.collect_artifact(id: StringName)`, `ProgressState.has_ability(id: StringName)`, `ProgressState.has_artifact(id: StringName)`, `ProgressState.snapshot() -> Dictionary`.
- Produces a headless runner that exits with code 0 only when all registered tests pass.

- [ ] **Step 1: Write failing tests** for a fresh progress state, idempotent ability/artifact unlocks, and snapshots that contain only serializable primitive values.
- [ ] **Step 2: Run `godot --headless --path . --script tests/run_tests.gd` and verify that the tests fail because `ProgressState` and the runner are not implemented.
- [ ] **Step 3: Create the Godot project, InputMap action names, `ProgressState`, boot scene, and minimal test runner.** Keep progress data independent of scene nodes so levels and tests can construct it without a running world.
- [ ] **Step 4: Run the headless test command and verify PASS with non-zero exit on an intentionally failing assertion.
- [ ] **Step 5: Add project launch instructions and the chosen folder conventions to `README.md`.

### Task 2: Input, player movement, checkpoints, and accessibility

**Files:**
- Create: `scenes/player/player.tscn`
- Create: `scripts/player/player_controller.gd`
- Create: `scripts/core/checkpoint_manager.gd`
- Create: `scripts/ui/tutorial_prompt.gd`
- Create: `tests/unit/test_checkpoint_manager.gd`
- Modify: `project.godot`

**Interfaces:**
- `PlayerController.configure(progress: ProgressState)`, `PlayerController.respawn_at(point: Vector2)`, and signals `died`, `health_changed`, `ability_used`.
- `CheckpointManager.activate(id: StringName, spawn_position: Vector2)`, `CheckpointManager.respawn_state() -> Dictionary`.
- Input actions: `move_left`, `move_right`, `jump`, `dodge`, `attack`, `strong_attack`, `interact`, `use_potion`.

- [ ] **Step 1: Write failing tests** for checkpoint replacement, death restoration, no limited lives, and refusal to use locked abilities.
- [ ] **Step 2: Run the focused tests and verify failure.
- [ ] **Step 3: Implement `PlayerController` as a typed `CharacterBody2D` with movement, running, jumping, dodging, damage, death, and a data-driven locked/unlocked ability check.** Do not add a second movement mode for individual territories.
- [ ] **Step 4: Implement `CheckpointManager` so death restores position, health, potion charges, and current level state while retaining collected rewards and unlocked abilities.
- [ ] **Step 5: Add tutorial prompts that are event-driven and dismissible; show the safe practice prompt before the first required use of each newly unlocked action.
- [ ] **Step 6: Run the focused headless tests and manually verify keyboard and gamepad mappings in the main scene.

### Task 3: Combat kernel and reusable encounter contracts

**Files:**
- Create: `scripts/combat/attack_controller.gd`
- Create: `scripts/combat/hitbox.gd`
- Create: `scripts/combat/hurtbox.gd`
- Create: `scripts/combat/health_component.gd`
- Create: `scripts/encounters/encounter_controller.gd`
- Create: `scripts/encounters/encounter_phase.gd`
- Create: `tests/unit/test_combat_kernel.gd`
- Create: `tests/unit/test_encounter_controller.gd`

**Interfaces:**
- `AttackController.request(kind: StringName) -> bool`, with kinds `normal`, `strong`, `air_strong`, `combo_step`.
- `EncounterController.start()`, `EncounterController.on_enemy_defeated(enemy_id: StringName)`, `EncounterController.advance_phase()`, and signals `phase_started(index)`, `completed`.
- `HealthComponent.damage(amount: int, source: StringName)`, `HealthComponent.is_defeated() -> bool`.

- [ ] **Step 1: Write failing tests** for normal attack, cooldown on strong attack, three-hit combo only after its unlock, air-strong only after its unlock, and bounded potion charges.
- [ ] **Step 2: Write failing encounter tests** proving that a phase cannot advance while required enemies remain and that completion fires once.
- [ ] **Step 3: Run the focused tests and verify failure.
- [ ] **Step 4: Implement hitbox/hurtbox and health components with explicit ownership/filtering so a hit cannot damage its source.
- [ ] **Step 5: Implement attack timing and the ability gates against `ProgressState`; use fixed windows rather than frame-count assumptions.
- [ ] **Step 6: Implement reusable encounter phases from data: required enemy count, spawn points, hazard pattern, completion condition, and optional reward.
- [ ] **Step 7: Run headless combat and encounter tests; manually test pause, repeated input, and attacks at the arena boundary.

### Task 4: Moscow vertical slice and first artifact

**Files:**
- Create: `scenes/levels/moscow.tscn`
- Create: `scenes/levels/moscow/lightroom.tscn`
- Create: `scenes/levels/moscow/rolex.tscn`
- Create: `scenes/levels/moscow/nikolskaya.tscn`
- Create: `scenes/levels/moscow/construction.tscn`
- Create: `scenes/encounters/crane_boss.tscn`
- Create: `scripts/levels/moscow_flow.gd`
- Create: `scripts/encounters/crane_boss.gd`
- Create: `tests/integration/test_moscow_flow.gd`

**Interfaces:**
- `MoscowFlow.complete_level() -> void` collects `cigar_cutter`, enables the first base state, and returns the player to the base transition.
- `CraneBoss` exposes exactly two phases: mob summons plus shadow hook, then readable top/bottom attacks.

- [ ] **Step 1: Write an integration test** that starts without damage, creates the coal sword in Lightroom, unlocks combat, traverses the ordered rooms, defeats the crane, and collects exactly one `cigar_cutter`.
- [ ] **Step 2: Run the integration test and verify failure because the scenes and flow do not exist.
- [ ] **Step 3: Build the smallest playable Moscow route:** Lightroom escape and coal puzzle, return fight, Rolex encounter, four-sequence lantern puzzle at Nikolskaya, construction route, and bridge transition.
- [ ] **Step 4: Implement the two-phase crane encounter using the reusable encounter contract; attacks must telegraph before damage and have a dodge/jump-safe answer.
- [ ] **Step 5: Implement the post-boss scene where the hook and arrow break the cutter supports and Юля takes the artifact; do not add a second weapon system.
- [ ] **Step 6: Run headless integration tests and play the complete route with keyboard/gamepad.** Acceptance: a new player can reach the sword and understand the first attack from prompts without external instructions.

### Task 5: Warehouse, tattoo recovery, and Lana encounter

**Files:**
- Create: `scenes/levels/warehouse.tscn`
- Create: `scenes/encounters/kitten_hydra.tscn`
- Create: `scenes/encounters/papy_flowers.tscn`
- Create: `scenes/encounters/skelberry.tscn`
- Create: `scenes/encounters/lana_del_rey.tscn`
- Create: `scripts/levels/warehouse_flow.gd`
- Create: `scripts/encounters/lana_encounter.gd`
- Create: `tests/integration/test_warehouse_rewards.gd`
- Create: `tests/integration/test_lana_encounter.gd`

**Interfaces:**
- Each mini-boss emits `reward_granted(id: StringName)` once: `kittens`, `papy_flowers`, `skelberry`.
- `LanaEncounter` has three phases, `on_wave_cleared()`, `advance_song()`, `complete()`, and no damage/HP interface.

- [ ] **Step 1: Write failing tests** for the four kitten heads returning one-by-one, the three-hit combo reward, Papy Flowers granting air-strong, Skelberry granting potion charges, and the rescue of Кирилл Портак.
- [ ] **Step 2: Write failing Lana tests** proving that each phase ends after its wave is cleared, the arena changes between songs, and no player attack can reduce Lana HP.
- [ ] **Step 3: Run focused tests and verify failure.
- [ ] **Step 4: Implement the warehouse route and three mini-bosses with short, readable arenas and automatic tattoo return moments; do not create a tattoo inventory UI.
- [ ] **Step 5: Implement Lana as a background performance with an initial ashtray, three songs, expanding mob composition, ash deposits, and final smoke/paint return into Юля.
- [ ] **Step 6: Collect `ashtray` as the second artifact and update `ProgressState`; place Портак’s departure and base arrival in the level flow, not in boss logic.
- [ ] **Step 7: Run integration tests and manually verify that the player can win Lana by clearing waves rather than attacking the background head.

### Task 6: Base state and automatic post-level presentation

**Files:**
- Create: `scenes/levels/base.tscn`
- Create: `scripts/base/base_controller.gd`
- Create: `scripts/base/base_state_view.gd`
- Create: `scripts/ui/satellite_screen.gd`
- Create: `tests/unit/test_base_state_view.gd`

**Interfaces:**
- `BaseController.apply_progress(progress: ProgressState) -> void` maps artifacts to visible states: cutter, ashtray/Pортак tower, lighter/Lиза house, mouthpiece/stairs/Шизик zone.
- `BaseController.begin_finale() -> bool` returns false and shows the warning until the player has all four artifacts and confirms.
- `SatelliteScreen.describe_anomaly(mutation_strength: int, object_size: int) -> StringName` returns `strong_mutation` or `artifact_candidate`.

- [ ] **Step 1: Write failing tests** for each artifact-to-base mapping, missing-artifact rejection, and final-start warning.
- [ ] **Step 2: Implement the automatic base view; characters and props are added by progress state, never by manual construction.
- [ ] **Step 3: Implement the deliberately absurd satellite interface and short dialogue/transition hooks for selecting the next expedition.
- [ ] **Step 4: Run headless tests and manually verify that the base can be walked through after each act without turning into a management screen.

### Task 7: Ryazan and the two-phase local boss

**Files:**
- Create: `scenes/levels/ryazan.tscn`
- Create: `scenes/levels/ryazan/bridge.tscn`
- Create: `scenes/levels/ryazan/attic.tscn`
- Create: `scenes/levels/ryazan/zazhigalka.tscn`
- Create: `scenes/encounters/lisa_boss.tscn`
- Create: `scripts/encounters/lisa_boss.gd`
- Create: `tests/integration/test_ryazan_flow.gd`

**Interfaces:**
- `LisaBoss` exposes `phase_lisa` and `phase_system`; `break_crown()` transitions to the second phase and removes Lisa from its enemy roster.
- `RyazanFlow.complete_level()` grants `lighter_heart` and schedules the slideshow, without requiring free-roam after victory.

- [ ] **Step 1: Write failing tests** for the ordered bridge → attic → roof → Зажигалка route, crown break, Lisa leaving the second phase, and the absence of a third phase.
- [ ] **Step 2: Implement the personal locations as short playable spaces; use the real reference photos/videos only as art input, without inventing an address or name not supplied by the creator.
- [ ] **Step 3: Implement the two-phase boss: Lisa under the watermelon crown, then the watermelon body/ketchup limbs organism.
- [ ] **Step 4: Implement the gratitude slideshow and `lighter_heart` artifact; do not add an open-city post-boss segment.
- [ ] **Step 5: Run integration tests and manually verify that the emotional attic beat does not stop the game with an unskippable long flashback.

### Task 8: Danang, syringe boss, and complete artifact assembly

**Files:**
- Create: `scenes/levels/danang.tscn`
- Create: `scenes/encounters/syringe_boss.tscn`
- Create: `scripts/levels/danang_flow.gd`
- Create: `scripts/encounters/syringe_boss.gd`
- Create: `tests/integration/test_danang_flow.gd`
- Modify: `scenes/levels/base.tscn`

**Interfaces:**
- `DanangFlow.complete_level()` grants `mouthpiece`, transports Шизик and unnamed followers to base, and changes the remote-business presentation state.
- `SyringeBoss` exposes readable attack telegraphs, an acceleration curve, `cut_into_mouthpiece()`, and emits `defeated` exactly once.

- [ ] **Step 1: Write failing tests** for entering Danang without a personal meeting with Шизик, defeating the syringe, creating the mouthpiece from its body, and reaching four collected artifacts.
- [ ] **Step 2: Build the pre-boss route from reused enemies, tight arenas, hazards, combo, air-strong attack, dodge, and potion; do not introduce drug-use simulation or a new mandatory system.
- [ ] **Step 3: Implement the syringe’s escalating but telegraphed pattern and the post-boss cut/needle-break presentation.
- [ ] **Step 4: Add Шизик’s first autonomous order and the arrival of Шизик plus unnamed followers at the base.
- [ ] **Step 5: Run integration tests and perform a first full-game traversal from Moscow through Danang.

### Task 9: Finale, three boss phases, ritual, and post-finale state

**Files:**
- Create: `scenes/levels/finale.tscn`
- Create: `scenes/encounters/portak_finale.tscn`
- Create: `scenes/encounters/watchman_finale.tscn`
- Create: `scenes/encounters/sanboy_finale.tscn`
- Create: `scripts/finale/finale_flow.gd`
- Create: `tests/integration/test_finale_flow.gd`

**Interfaces:**
- `FinaleFlow.start()` requires all four artifacts and freezes free movement on the base only after confirmation.
- `FinaleFlow.complete_phase(id: StringName)` advances `portak` → `watchman` → `sanboy`.
- `FinaleFlow.complete_ritual()` clears dangerous mutation, preserves harmless tattoo movement, and marks the main run complete.

- [ ] **Step 1: Write failing tests** for phase order, immunity of Lisa/Шизик, control of Портак and Смотритель, Sanboy appearing only after Смотритель, and the non-lethal meaning of “price of life”.
- [ ] **Step 2: Implement the three finale encounters on the existing combat kernel; Sanboy may be the most theatrical but not necessarily the hardest.
- [ ] **Step 3: Implement the gratitude fire, lighter-heart activation, Sмотритель’s mechanism action, Юля’s ascent, and cigarette inhale sequence.
- [ ] **Step 4: Implement the smoke reveal with the exact approved emotional outcome: Юля survives, says “Я воин”, and the dangerous mutation disappears while tattoo remnants remain.
- [ ] **Step 5: Run integration tests and manually complete the finale once without skipping cinematic transitions.

### Task 10: Epilogue, video message, replay menu, and platform verification

**Files:**
- Create: `scenes/epilogue/epilogue.tscn`
- Create: `scripts/epilogue/epilogue_controller.gd`
- Create: `scenes/ui/memory_menu.tscn`
- Create: `scripts/ui/memory_menu.gd`
- Create: `scripts/platform/performance_probe.gd`
- Create: `tests/integration/test_postgame_menu.gd`
- Create: `docs/qa/us6-playtest-checklist.md`
- Modify: `README.md`

**Interfaces:**
- `EpilogueController.play()`, `EpilogueController.replay()`, and `EpilogueController.open_video()` provide a no-input montage followed by the mandatory video message.
- `MemoryMenu.replay_level(level_id: StringName)` starts that level with its original progression state and does not mutate the main save.
- `PerformanceProbe.sample(duration_seconds: float) -> Dictionary` reports frame time, peak active enemies, particles, and draw-call budget.

- [ ] **Step 1: Write failing tests** for epilogue order, mandatory video availability, replay of all four territories plus finale, and no transfer of combo/potions between replayed levels.
- [ ] **Step 2: Implement the crime-film-style epilogue as replaceable stills/slides with captions and short scenes; finish on Юля and Смотритель together.
- [ ] **Step 3: Implement the ashtray memory menu, replay isolation, and repeatable video launch.
- [ ] **Step 4: Add performance probes and a release checklist covering scene load, input, checkpoint, boss phase, audio, video playback, and controller operation.
- [ ] **Step 5: Run the complete headless suite, `godot --headless --path . --editor --quit`, and a full manual playthrough.
- [ ] **Step 6: Run the performance probe on desktop and the selected portable target. If the target misses budget, simplify particles, background layers, or secondary transitions before considering any format change; keep the game 2D.
- [ ] **Step 7: Record a timed first-playthrough. Acceptance is at least three hours of meaningful first-run content, no progression blocker, and a complete build containing the video message.

## Production Order and Milestones

1. **Week 1:** Tasks 1–3; a tested player can move, dodge, attack, die, respawn, and unlock abilities.
2. **Week 2:** Task 4; Moscow is a complete playable vertical slice and becomes the quality bar for controls, camera, enemy readability, and scene transitions.
3. **Weeks 3–4:** Tasks 5–6; warehouse/Lana and an automatically evolving base are playable end-to-end.
4. **Week 5:** Task 7; Ryazan is playable with exactly two boss phases and a working lighter-heart reward.
5. **Week 6:** Task 8; Danang completes the artifact set and the base can start the finale.
6. **Week 7:** Tasks 9–10; finale, epilogue, video, replay menu, and performance pass exist in one build.
7. **Week 8:** bug fixing, accessibility tuning, asset replacement, timing pass, target-device testing, and cut-list decisions. No new mechanics in this week.

## Cut List if the Schedule Slips

Cut in this order: secondary dialogue, optional base interactions, decorative transitions, extra enemy variants, and elaborate cinematic animation. Preserve the four territories, their artifacts, the two-phase Ryazan boss, Lana’s three-song structure, the three finale phases, the epilogue, and the personal video message.

## Self-Review

- **Spec coverage:** Tasks 1–3 cover the shared controls, progression, accessibility, and combat. Tasks 4–8 cover the four territories, artifacts, bosses, and evolving base. Task 9 covers the finale and mutation resolution. Task 10 covers epilogue, video, replay, performance, and the three-hour acceptance criterion.
- **Interface consistency:** All level rewards use `ProgressState.collect_artifact`; all combat rewards use `unlock_ability`; bosses advance through `EncounterController`; base and finale consume the same progress object.
- **Main uncovered risks:** exact visual style, final songs, full enemy attack lists, real-location references, audio mix, and final video encoding remain content decisions from the spec’s unresolved-details section. They are intentionally behind replaceable scene/data boundaries rather than blocking the combat prototype.
- **Scope check:** The plan is an umbrella release plan, but each task produces an independently testable slice. If implementation begins to require parallel teams, split Tasks 4–10 into separate subsystem plans without changing the contracts listed above.
