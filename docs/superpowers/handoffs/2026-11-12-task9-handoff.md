# US6 — handoff для Task 9

## Цель следующего чата

Продолжить разработку US6 с **Task 9: финальный бой, ритуал и пост-финальное состояние**.

Task 8 завершён и опубликован: playable Дананг, `SyringeBoss`, `mouthpiece`, спасение Шизика, прибытие Шизика и безымянных прихвостней на базу, четыре артефакта и integration tests.

Task 9 должен использовать все четыре артефакта и завершить основной игровой конфликт, но не должен начинать работу над полноценным эпилогом, меню воспоминаний или обязательным видео — это Task 10.

## Текущее состояние репозитория

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Последний commit: `5ca71d1 Implement Task 8 Danang and syringe boss`
- Ожидаемое состояние ветки: `main...origin/main`
- Рабочее дерево после Task 8 чистое.
- Godot может автоматически форматировать `project.godot` после editor-load check. Если diff содержит только автоматическое форматирование, выполнить `git restore -- project.godot` и не коммитить этот шум.

## Обязательная проверка перед изменениями

Сначала выполнить именно эти команды:

```powershell
cd E:\US6
git status --short --branch
git log --oneline -5
git diff -- project.godot
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --script res://tests/run_tests.gd
```

Ожидаемый baseline после Task 8:

```text
--- ProgressState ---
PASS
--- Player ---
PASS
--- CheckpointManager ---
PASS
--- CombatKernel ---
PASS
--- EncounterController ---
PASS
--- MoscowFlow ---
PASS
--- WarehouseRewards ---
PASS
--- LanaEncounter ---
PASS
--- BaseState ---
PASS
--- RyazanFlow ---
PASS
--- DanangFlow ---
PASS
=== ALL PASS ===
```

Возможны стандартные Godot warnings о leaked CanvasItem/ObjectDB resources в headless runner; они не заменяют ошибки тестов и должны быть отдельно указаны в отчёте.

## Обязательные документы для чтения

Перед планированием и изменениями прочитать:

```text
docs/superpowers/specs/2026-11-12-us6-master-design.md
docs/superpowers/plans/2026-11-12-us6-implementation.md
docs/superpowers/handoffs/2026-11-12-task8-handoff.md
docs/superpowers/handoffs/2026-11-12-task9-handoff.md
```

Также изучить существующие реализации и тесты:

```text
scripts/core/progress_state.gd
scripts/base/base_controller.gd
scripts/base/base_state_view.gd
scripts/encounters/encounter_controller.gd
scripts/encounters/encounter_phase.gd
scripts/encounters/lisa_boss.gd
scripts/encounters/syringe_boss.gd
scenes/levels/base.tscn
tests/run_tests.gd
tests/unit/test_base_state_view.gd
tests/integration/test_danang_flow.gd
```

## Уже реализовано и не требует переписывания

### Общие системы Task 1–3

- `ProgressState` с abilities/artifacts и serializable snapshot.
- Headless runner `tests/run_tests.gd`.
- Player/checkpoint foundation.
- `AttackController` с `normal`, `strong`, `combo_step`, `air_strong`, `use_potion`.
- Strong cooldown.
- Ability gates через единый `ProgressState`.
- Combo ограничен тремя шагами.
- Potion charges bounded.
- `HealthComponent`, `Hitbox`, `Hurtbox` с фильтрацией self-hit.
- `EncounterPhase`, `EncounterController`.

### Task 4 — Moscow

- `cigar_cutter` и существующий playable flow.

### Task 5 — Warehouse/Lana

- `ashtray`, татуировки и существующие playable encounters.

### Task 6 — Base

- `BaseController` и `BaseStateView`.
- `BaseController.REQUIRED_ARTIFACTS` уже содержит:
  - `cigar_cutter`
  - `ashtray`
  - `lighter_heart`
  - `mouthpiece`
- Финал уже требует все четыре артефакта и явное подтверждение.
- `BaseStateView` отображает `mouthpiece`, `stairs` и `shizik_zone` по `ProgressState`.

### Task 7 — Ryazan/Lisa

- `lighter_heart`.
- Двухфазный `LisaBoss`.

### Task 8 — Danang/Syringe

- `mouthpiece`.
- `DanangFlow` с маршрутом и post-boss presentation state.
- `SyringeBoss` с telegraphs, acceleration curve и однократным `defeated`.
- Шизик и безымянные прихвостни отмечены прибывшими на базу.
- Полный suite и smoke-load новых сцен проходят.

## Task 9 — цель

Реализовать финальную последовательность US6:

```text
Base confirmation → Portak phase → Watchman phase → Sanboy phase → ritual → post-finale state
```

Финал должен:

- требовать все четыре артефакта;
- начинаться только после явного подтверждения игрока;
- отключать свободное движение по базе только после подтверждения финала;
- проводить три боевые фазы в фиксированном порядке;
- не делать Лизу и Шизика противниками финала;
- освободить Портака и Смотрителя после соответствующих фаз;
- показать Санбоя только после поражения Смотрителя;
- завершить ритуал без смерти Юли;
- очистить опасную мутацию и сохранить безвредную жизнь татуировок;
- отметить основной run завершённым;
- не запускать эпилог, replay menu или обязательное видео.

## Обязательные плановые файлы

Создать:

- `scenes/levels/finale.tscn`
- `scenes/encounters/portak_finale.tscn`
- `scenes/encounters/watchman_finale.tscn`
- `scenes/encounters/sanboy_finale.tscn`
- `scripts/finale/finale_flow.gd`
- `tests/integration/test_finale_flow.gd`

Дополнительные файлы допустимы только если они являются частью ясного finale-контракта или playable/presentation scene. Не создавать отдельный progression manager, отдельный inventory или второе боевое ядро.

## Рекомендуемые контракты

### `FinaleFlow`

Минимальный observable API:

```gdscript
start() -> bool
confirm_start() -> bool
complete_phase(id: StringName) -> bool
complete_ritual() -> bool
```

Рекомендуемые observable fields/signals:

```gdscript
current_phase: StringName
phases: Array[StringName]
finale_started: bool
free_movement_locked: bool
main_run_completed: bool
mutation_cleared: bool
harmless_tattoos_preserved: bool
phase_started
phase_completed
ritual_completed
```

Требуемое поведение:

- `start()` возвращает `false`, если не хватает хотя бы одного артефакта;
- `start()` возвращает `false` до явного подтверждения, но выставляет состояние предупреждения;
- только `confirm_start()` после проверки четырёх артефактов запускает финал;
- повторный `start()`/`confirm_start()` не перезапускает финал и не сбрасывает прогресс;
- `complete_phase()` принимает только текущую фазу;
- порядок строго: `portak → watchman → sanboy`;
- нельзя завершить `watchman` до `portak`;
- нельзя начать `sanboy` до завершения `watchman`;
- нельзя завершить ритуал до `sanboy`;
- после `complete_ritual()` повторный вызов не создаёт второе завершение;
- Task 9 не должен изменять unrelated abilities или artifacts.

### Финальные фазы

#### Portak

- Портак находится под контролем US6.
- Использует существующее боевое ядро и понятные telegraphs.
- После победы Портак освобождён.
- Лиза и Шизик не входят в roster этой фазы.

#### Watchman

- Смотритель находится под контролем US6.
- Использует самодельные устройства, провода и кустарную электронику как безопасные абсурдные визуальные маркеры.
- После победы Смотритель освобождён и предупреждает Юлю о Санбое.

#### Sanboy

- Санбой появляется только после поражения Смотрителя.
- Санбой — самостоятельный аватар US6, а не случайный новый враг.
- Фаза должна быть наиболее постановочной, но не обязана быть самой сложной.
- После победы Санбой признаёт Юлю ИСТИННЫМ ГЕРОЕМ и исчезает.

## Ритуал и post-finale state

`complete_ritual()` должен реализовать минимальное проверяемое состояние:

- благодарность друзей и безликих прихвостней может быть presentation flag, а не отдельной системой;
- `lighter_heart` активирован;
- Смотритель запускает механизм;
- Юля поднимается к сигаре;
- Юля остаётся жива;
- dangerous mutation cleared;
- harmless tattoo motion preserved;
- main run completed;
- свободное перемещение после финала может быть ограничено или переведено в post-finale presentation state.

Обязательный эмоциональный результат:

```text
Юля выходит из дыма живой и признаёт, что она воин.
```

В Task 9 достаточно observable flags/state и короткой presentation сцены. Полноценный монтаж эпилога, replay menu и видеопослание относятся к Task 10.

## Обязательный TDD-порядок

1. Написать failing tests для блокировки финала без всех четырёх артефактов.
2. Написать failing tests для явного подтверждения финала и блокировки свободного движения только после подтверждения.
3. Написать failing tests для порядка `portak → watchman → sanboy`.
4. Написать failing tests для появления Санбоя только после поражения Смотрителя.
5. Написать failing tests, что Лиза и Шизик не становятся финальными противниками.
6. Написать failing tests для освобождения Портака и Смотрителя.
7. Написать failing tests для ritual outcome: Юля жива, dangerous mutation cleared, harmless tattoos preserved.
8. Написать failing test для идемпотентности `complete_ritual()` и `main_run_completed`.
9. Подключить `test_finale_flow.gd` к `tests/run_tests.gd`.
10. Запустить focused/full suite и зафиксировать RED до production implementation.
11. Реализовать минимальный `FinaleFlow` поверх существующих `ProgressState` и `BaseController` contracts.
12. Создать playable/presentation `finale.tscn` с понятной ареной и переходом между фазами.
13. Создать три encounter scenes с визуально различимыми силуэтами и readable telegraphs.
14. Подключить финальные фазы к flow, не создавая параллельное combat ядро.
15. Реализовать минимальную ritual presentation без запуска Task 10.
16. Запустить полный headless suite.
17. Выполнить editor-load check:

```powershell
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --editor --quit
```

18. Выполнить project/scene checker, если он существует в репозитории, и smoke-load всех новых finale scenes.
19. Проверить, что `project.godot` не получил только автоматическое форматирование; при необходимости выполнить `git restore -- project.godot`.
20. После зелёного рабочего среза сделать commit и push.

## Границы Task 9

- Не переписывать Task 1–8.
- Использовать существующий `ProgressState`.
- Использовать существующие player/combat/encounter contracts.
- Не добавлять новый способ управления.
- Не добавлять RPG-инвентарь или отдельный инвентарь татуировок.
- Не добавлять отдельный progression manager.
- Не запускать эпилог, replay menu или обязательное видео.
- Не делать Лизу или Шизика финальными врагами.
- Не делать финал открытым исследованием мира.
- Не превращать ritual в обязательную смерть Юли.
- Использовать безопасные абсурдные визуальные маркеры: паутина, провода, кустарная электроника, велосипед, гитара, дым и космическая сигара.

## Критерий закрытия Task 9

Task 9 можно считать закрытым только если одновременно выполнены все условия:

- полный headless suite зелёный;
- финал заблокирован без всех четырёх артефактов;
- финал требует явного подтверждения;
- свободное движение блокируется только после подтверждения;
- фазы проходят строго `portak → watchman → sanboy`;
- Санбой появляется только после Смотрителя;
- Лиза и Шизик не являются финальными противниками;
- Портак и Смотритель отмечены освобождёнными;
- ритуал идемпотентен;
- Юля остаётся жива;
- dangerous mutation очищена;
- harmless tattoo motion сохранён;
- основной run отмечен завершённым;
- Task 10 не запускается автоматически;
- `finale.tscn` и три encounter scenes загружаются;
- editor-load check выполнен;
- commit создан и push выполнен в `origin/main`;
- рабочее дерево чистое.

## Обязательный финальный отчёт нового чата

Сообщить:

- какие файлы изменены;
- какие тесты прошли;
- RED и GREEN результаты TDD;
- как проверены порядок фаз и блокировка финала;
- как проверены ritual outcome и идемпотентность;
- commit hash;
- результат `git push`;
- состояние `git status --short --branch`;
- сознательные решения;
- отложенные polish-детали;
- подтверждение, что эпилог, replay menu и видео оставлены для Task 10.
