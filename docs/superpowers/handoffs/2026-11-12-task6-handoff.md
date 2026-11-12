# US6 — handoff для Task 6

## Цель следующего чата

Продолжить разработку US6 с **Task 6: база и автоматическая презентация прогресса**.

Task 5 закрыт как логический/тестируемый вертикальный срез: склад, восстановление татуировок, награды мини-боссов, Lana encounter и второй артефакт `ashtray` реализованы, протестированы и опубликованы.

## Текущее состояние репозитория

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Последний опубликованный коммит перед handoff: `41cde8f Implement Task 5 warehouse and Lana encounter`
- Ожидаемое состояние ветки: `main...origin/main`
- `project.godot` может быть изменён автоматическим форматированием Godot. Перед работой проверить `git diff -- project.godot`; если это только форматирование, выполнить `git restore -- project.godot` и не коммитить шум.

## Обязательная проверка перед изменениями

Сначала выполнить именно эти команды:

```powershell
cd E:\US6
git status --short --branch
git log --oneline -5
git diff -- project.godot
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --script res://tests/run_tests.gd
```

Ожидаемый baseline полного runner:

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
=== ALL PASS ===
```

## Уже реализовано

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

- `scripts/levels/moscow_flow.gd`:
  - порядок `lightroom → rolex → nikolskaya → construction`;
  - `create_coal_sword()` открывает `combat`, `normal_attack`, `strong_attack`;
  - `complete_level()` один раз выдаёт `cigar_cutter` и переводит flow в `base`.
- `scripts/encounters/crane_boss.gd`:
  - phase 0: `summoned_mob`, `shadow_hook`;
  - phase 1: `top_attack`, `bottom_attack`;
  - завершение после обеих фаз.
- `scenes/levels/moscow.tscn` — playable shell.
- `scenes/encounters/crane_boss.tscn`.
- `tests/integration/test_moscow_flow.gd`.

### Task 5 — Warehouse/Lana

- `scripts/levels/warehouse_flow.gd`:
  - маршрут склада;
  - награды мини-боссов;
  - `portak_rescued` устанавливается в level flow;
  - `complete_level()` выдаёт `ashtray` ровно один раз и переводит flow в `base`.
- `scripts/encounters/kitten_hydra.gd`:
  - четыре уникальные головы;
  - повторное поражение одной головы не засчитывается;
  - `reward_granted(&"kittens")` ровно один раз.
- `scripts/encounters/papy_flowers.gd`:
  - `reward_granted(&"papy_flowers")` ровно один раз.
- `scripts/encounters/skelberry.gd`:
  - `reward_granted(&"skelberry")` ровно один раз.
- `scripts/encounters/lana_encounter.gd`:
  - три песни/фазы;
  - `on_wave_cleared()`, `advance_song()`, `complete()`;
  - расширяющийся состав волн;
  - нет HP, `damage()` или `take_damage()`.
- Playable scenes:
  - `scenes/levels/warehouse.tscn`;
  - `scenes/encounters/kitten_hydra.tscn`;
  - `scenes/encounters/papy_flowers.tscn`;
  - `scenes/encounters/skelberry.tscn`;
  - `scenes/encounters/lana_del_rey.tscn`.
- `tests/integration/test_warehouse_rewards.gd`.
- `tests/integration/test_lana_encounter.gd`.

## Task 6 — контракт

### Плановые файлы

Создать:

- `scenes/levels/base.tscn`
- `scripts/base/base_controller.gd`
- `scripts/base/base_state_view.gd`
- `scripts/ui/satellite_screen.gd`
- `tests/unit/test_base_state_view.gd`

### Обязательные интерфейсы

#### `BaseController`

Должен предоставлять:

```gdscript
apply_progress(progress: ProgressState) -> void
begin_finale() -> bool
```

`apply_progress()` автоматически отображает состояние базы по артефактам `ProgressState`:

| Артефакт | Состояние базы |
|---|---|
| `cigar_cutter` | сигара/резак и первый домик Смотрителя |
| `ashtray` | пепельница и маленькая башня Кирилла Портака |
| `lighter_heart` | зажигалка и домик Лизы |
| `mouthpiece` | мундштук, лестница и зона Шизика |

Состояние должно быть производным от `ProgressState`, а не отдельным несинхронизируемым инвентарём.

`begin_finale()`:

- возвращает `false`, если не собраны все четыре артефакта;
- показывает/фиксирует предупреждение о необратимом запуске финала;
- после подтверждения может вернуть `true` и перевести базу в состояние начала финала;
- не должен запускать финал без явного подтверждения.

Если для тестируемого контракта нужен отдельный метод подтверждения, выбрать минимальный typed API и покрыть его тестом. Не добавлять новую систему сохранений или отдельный inventory UI.

#### `BaseStateView`

Рекомендуемый data-driven контракт:

```gdscript
apply_progress(progress: ProgressState) -> void
has_state(id: StringName) -> bool
visible_states() -> Array[StringName]
```

Названия состояний должны быть стабильными и тестируемыми, например:

```text
cutter
portak_tower
ashtray
lighter_house
mouthpiece
stairs
shizik_zone
```

Один источник истины — `ProgressState.artifacts`; view не должна самостоятельно выдавать артефакты.

#### `SatelliteScreen`

Должен предоставлять:

```gdscript
describe_anomaly(mutation_strength: int, object_size: int) -> StringName
```

Минимальный контракт:

- сильная мутация → `&"strong_mutation"`;
- слабая мутация с крупным объектом → `&"artifact_candidate"`;
- остальные случаи → стабильный нейтральный результат, например `&"weak_mutation"`.

Это абсурдный интерфейс спутниковых снимков, а не отдельная сложная система разведки.

## Поведение Task 6

1. После `cigar_cutter` база показывает первый домик/состояние резака.
2. После `ashtray` автоматически появляется пепельница и башня Портака.
3. После `lighter_heart` автоматически появляются зажигалка и домик Лизы.
4. После `mouthpiece` автоматически появляются мундштук, лестница и зона Шизика.
5. Повторный `apply_progress()` идемпотентен: состояния не дублируются.
6. Если артефакт убрать из тестового `ProgressState` и снова применить его к view, состояние должно быть пересчитано предсказуемо; не оставлять stale-предметы без решения в контракте.
7. Начало финала блокируется без всех четырёх артефактов.
8. Предупреждение перед финалом требует подтверждения.
9. База остаётся прогулочной презентацией, а не экраном менеджмента или строительства.
10. Смотритель, Портак, Лиза и Шизик появляются автоматически вместе с соответствующими состояниями; ручное строительство не добавляется.

## TDD-порядок

1. Написать failing tests для каждого artifact-to-base mapping.
2. Добавить тесты идемпотентности и отсутствия stale/дублированных состояний.
3. Добавить failing tests для отказа `begin_finale()` без артефактов и требования подтверждения.
4. Добавить тесты `SatelliteScreen.describe_anomaly()`.
5. Запустить focused/full runner и зафиксировать RED.
6. Реализовать минимальные `BaseStateView`, `BaseController`, `SatelliteScreen`.
7. Создать playable `base.tscn` с фоном, полом, игроком, камерой и подсказкой управления.
8. Подключить `test_base_state_view.gd` к `tests/run_tests.gd`.
9. Запустить полный headless suite и editor-load check.
10. Если `project.godot` изменён только Godot-форматированием, восстановить файл.
11. После зелёного рабочего среза сделать commit, push и краткий отчёт.

## Границы Task 6

- Не переписывать Task 1–5.
- Не создавать отдельный UI-инвентарь татуировок.
- Не добавлять новую схему управления.
- Не превращать базу в менеджмент, строительство или RPG-инвентарь.
- Не добавлять финальный бой, Рязань или Дананг в рамках Task 6.
- Не выдавать артефакты из `BaseController`; он только отображает уже имеющийся `ProgressState`.
- Не блокировать свободное перемещение по базе до подтверждённого запуска финала.
- Placeholder-геометрия допустима, но новые сцены не должны быть пустыми серыми контейнерами.

## Критерий закрытия Task 6

Task 6 можно считать закрытым одновременно только если:

- полный headless suite зелёный;
- все четыре artifact-to-base mapping покрыты тестами;
- `apply_progress()` идемпотентен и не создаёт дублей;
- `begin_finale()` отклоняется без полного набора артефактов;
- запуск финала требует подтверждения;
- satellite anomaly contract покрыт тестами;
- `base.tscn` загружается и имеет playable shell;
- рабочее дерево чистое;
- commit создан и push выполнен в `origin/main`.

## Обязательный финальный отчёт нового чата

Новый агент должен сообщить:

- какие файлы изменены;
- какие тесты прошли;
- какой commit hash создан;
- результат `git push`;
- состояние `git status --short --branch`;
- отдельную оговорку о любых сознательных решениях или отложенных polish-деталях.
