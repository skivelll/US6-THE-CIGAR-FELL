# US6 — handoff для Task 7

## Цель следующего чата

Продолжить разработку US6 с **Task 7: Рязань и двухфазный локальный босс**.

Task 6 закрыт: playable-база, автоматическое отображение состояния по `ProgressState`, satellite contract и блокировка финала реализованы, протестированы и опубликованы.

## Текущее состояние репозитория

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Последний commit: `cbe9747 Implement Task 6 base presentation`
- Ожидаемое состояние ветки: `main...origin/main`
- Рабочее дерево после handoff должно быть чистым.
- Godot может автоматически форматировать `project.godot` после запуска editor-load check. Если diff содержит только форматирование, выполнить `git restore -- project.godot` и не коммитить этот шум.

## Обязательная проверка перед изменениями

Сначала выполнить именно эти команды:

```powershell
cd E:\US6
git status --short --branch
git log --oneline -5
git diff -- project.godot
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --script res://tests/run_tests.gd
```

Ожидаемый baseline:

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
=== ALL PASS ===
```

## Обязательные документы для чтения

Перед планированием и изменениями прочитать:

```text
docs/superpowers/specs/2026-11-12-us6-master-design.md
docs/superpowers/plans/2026-11-12-us6-implementation.md
docs/superpowers/handoffs/2026-11-12-task7-handoff.md
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

- `scripts/levels/moscow_flow.gd` с порядком `lightroom → rolex → nikolskaya → construction`.
- `create_coal_sword()` открывает `combat`, `normal_attack`, `strong_attack`.
- `complete_level()` выдаёт `cigar_cutter` ровно один раз и переводит flow в `base`.
- `scripts/encounters/crane_boss.gd` с двумя фазами.
- Playable `scenes/levels/moscow.tscn` и `scenes/encounters/crane_boss.tscn`.
- `tests/integration/test_moscow_flow.gd`.

### Task 5 — Warehouse/Lana

- `scripts/levels/warehouse_flow.gd` с маршрутом и наградами.
- `complete_level()` выдаёт `ashtray` ровно один раз и переводит flow в `base`.
- Мини-боссы котят, Papy Flowers и Skelberry.
- `scripts/encounters/lana_encounter.gd` с тремя песнями/фазами.
- Playable warehouse и encounter scenes.
- `tests/integration/test_warehouse_rewards.gd`.
- `tests/integration/test_lana_encounter.gd`.

### Task 6 — Base

- `scripts/base/base_controller.gd`.
- `scripts/base/base_state_view.gd`.
- `scripts/ui/satellite_screen.gd`.
- `scenes/levels/base.tscn`.
- `tests/unit/test_base_state_view.gd`, подключённый к runner.
- `BaseStateView` строит состояния только из артефактов `ProgressState`.
- `BaseController.begin_finale()` требует все четыре артефакта и явное `confirm_finale()`.

## Task 7 — цель

Реализовать Рязань как короткую playable территорию и двухфазного босса Лизу.

Порядок маршрута:

```text
bridge → attic → roof → zazhigalka
```

После завершения уровня выдать через единый `ProgressState` артефакт:

```text
lighter_heart
```

Свободная прогулка по освобождённой Рязани после победы не требуется. Завершение может запускать slideshow/transition hook, но отдельная большая система катсцен в Task 7 не нужна.

## Обязательные плановые файлы

Создать:

- `scenes/levels/ryazan.tscn`
- `scenes/levels/ryazan/bridge.tscn`
- `scenes/levels/ryazan/attic.tscn`
- `scenes/levels/ryazan/zazhigalka.tscn`
- `scenes/encounters/lisa_boss.tscn`
- `scripts/encounters/lisa_boss.gd`
- `tests/integration/test_ryazan_flow.gd`

Также допустимо создать минимальный flow-класс, если он нужен для ясного контракта, например `scripts/levels/ryazan_flow.gd`, но не добавлять лишние системы.

## Обязательные контракты

### `LisaBoss`

Должен предоставлять тестируемый контракт:

```gdscript
phase_lisa
phase_system
break_crown() -> bool
```

Требуемое поведение:

1. Начальная фаза — `phase_lisa`.
2. `break_crown()` переводит босса в `phase_system` ровно один раз.
3. После `break_crown()` Лиза удаляется из enemy roster второй фазы.
4. Вторая фаза — единый организм из арбуза и кетчупных конечностей.
5. Третьей фазы нет.
6. Повторный `break_crown()` не должен повторно выдавать награду или ломать состояние.
7. Завершение босса должно быть идемпотентным.

Названия внутренних полей и вспомогательных методов можно выбрать свободно, но observable contract должен быть стабильным и покрыт тестами.

### `RyazanFlow`

Рекомендуемый минимальный контракт:

```gdscript
enter_room(room: StringName) -> bool
complete_lisa_boss(boss: RefCounted) -> void
complete_level() -> void
```

Требуемое поведение:

- маршрут принимается только в порядке `bridge → attic → roof → zazhigalka`;
- победа над боссом должна быть условием завершения уровня;
- `complete_level()` выдаёт `lighter_heart` ровно один раз;
- после `complete_level()` flow переходит в `base` или возвращает эквивалентный переходный статус;
- повторный вызов не дублирует артефакт;
- flow не должен самостоятельно выдавать способности или менять unrelated progress.

## Обязательный TDD-порядок

1. Сначала написать failing tests для порядка маршрута Рязани.
2. Добавить failing tests для начальной фазы Лизы, `break_crown()`, удаления Лизы из второй фазы и отсутствия третьей фазы.
3. Добавить failing tests для завершения второй фазы и выдачи `lighter_heart` ровно один раз.
4. Подключить `test_ryazan_flow.gd` к `tests/run_tests.gd`.
5. Запустить focused/full suite и зафиксировать RED до production implementation.
6. Реализовать минимальные `LisaBoss` и `RyazanFlow`.
7. Создать playable `ryazan.tscn` и дочерние сцены с минимумом: фон, пол, игрок, камера и подсказка управления. Новые сцены не должны быть пустыми серыми контейнерами.
8. Создать `lisa_boss.tscn` с читаемой placeholder-ареной и визуальным разделением двух фаз.
9. Запустить полный headless suite.
10. Выполнить editor-load check:

```powershell
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --editor --quit
```

11. Если `project.godot` изменён только автоматическим форматированием Godot, восстановить его:

```powershell
git restore -- project.godot
```

12. После зелёного рабочего среза сделать commit, push и краткий отчёт.

## Границы Task 7

- Не переписывать Task 1–6.
- Использовать существующий `ProgressState`.
- Не добавлять новую схему управления.
- Не добавлять отдельный инвентарь татуировок, RPG-инвентарь или систему ручного строительства.
- Не добавлять Дананг, финальный бой или эпилог.
- Не превращать Рязань в открытый город.
- Не добавлять третью фазу Lisa boss.
- Не требовать свободного пост-боссового исследования города.
- Слайдшоу после освобождения может быть только минимальным replaceable transition hook.
- Использовать существующие combat/player contracts; не создавать параллельное боевое ядро.

## Критерий закрытия Task 7

Task 7 можно считать закрытым только если одновременно выполнены все условия:

- полный headless suite зелёный;
- маршрут `bridge → attic → roof → zazhigalka` покрыт integration tests;
- `LisaBoss` имеет ровно две фазы;
- `break_crown()` переводит фазу и удаляет Лизу из roster второй фазы;
- третья фаза отсутствует и покрыта тестом;
- `lighter_heart` выдаётся ровно один раз;
- playable `ryazan.tscn` и дочерние сцены загружаются;
- editor-load check выполнен;
- рабочее дерево чистое;
- commit создан и push выполнен в `origin/main`.

## Обязательный финальный отчёт нового чата

Сообщить:

- какие файлы изменены;
- какие тесты прошли;
- RED и GREEN результаты TDD;
- commit hash;
- результат `git push`;
- состояние `git status --short --branch`;
- сознательные решения и отложенные polish-детали.
