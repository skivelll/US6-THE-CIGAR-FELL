# US6 — handoff для Task 5

## Цель следующего чата

Продолжить разработку US6 с **Task 5: склад, восстановление татуировок и Lana encounter**.

Task 4 закрыт как логический/игровой вертикальный срез: Moscow-сцена запускается, движение работает, маршрут и двухфазный CraneBoss покрыты headless-тестом.

## Текущее состояние репозитория

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Последний опубликованный коммит: `d40c52b Fix test room controls and playable Moscow scene`
- Ветка на момент создания handoff: `main...origin/main`
- В рабочем дереве есть изменённый `project.godot`: Godot автоматически форматирует этот файл при открытии/загрузке проекта. Перед началом проверь diff и не коммить шумовое форматирование без отдельной причины.

## Уже реализовано

### Task 1–3

- `ProgressState` с abilities/artifacts и serializable snapshot.
- Headless runner: `tests/run_tests.gd`.
- Player/checkpoint foundation.
- `AttackController`:
  - `normal`, `strong`, `combo_step`, `air_strong`, `use_potion`;
  - cooldown strong;
  - gates способностей через `ProgressState`;
  - bounded potion charges.
- `HealthComponent`, `Hitbox`, `Hurtbox` с фильтрацией self-hit.
- `EncounterPhase`, `EncounterController`.

### Task 4

- `scripts/levels/moscow_flow.gd`:
  - порядок: `lightroom → rolex → nikolskaya → construction`;
  - `create_coal_sword()` открывает `combat`, `normal_attack`, `strong_attack`;
  - `complete_level()` выдаёт `cigar_cutter` ровно один раз и переводит flow в `base`.
- `scripts/encounters/crane_boss.gd`:
  - phase 0: `summoned_mob`, `shadow_hook`;
  - phase 1: `top_attack`, `bottom_attack`;
  - completion после обеих фаз.
- `scenes/levels/moscow.tscn` — минимальная запускаемая арена: фон, пол, платформа, стены, игрок, камера, подсказка управления.
- `scenes/encounters/crane_boss.tscn` — структурный контейнер арены.
- `tests/integration/test_moscow_flow.gd` подключён к общему runner.
- В `scripts/player/player_controller.gd` добавлен fallback прямого ввода A/D, стрелок, Space, Shift и Ctrl, чтобы ручная проверка не зависела только от повреждённого InputMap.

## Проверка перед началом Task 5

Запусти:

```powershell
cd E:\US6
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --script res://tests/run_tests.gd
```

Ожидается:

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
=== ALL PASS ===
```

Перед изменениями:

```powershell
git status --short --branch
git diff -- project.godot
```

Если `project.godot` содержит только автоформатирование, восстанови его:

```powershell
git restore -- project.godot
```

## Task 5 — контракт

### Плановые файлы

Создать:

- `scenes/levels/warehouse.tscn`
- `scenes/encounters/kitten_hydra.tscn`
- `scenes/encounters/papy_flowers.tscn`
- `scenes/encounters/skelberry.tscn`
- `scenes/encounters/lana_del_rey.tscn`
- `scripts/levels/warehouse_flow.gd`
- `scripts/encounters/lana_encounter.gd`
- `tests/integration/test_warehouse_rewards.gd`
- `tests/integration/test_lana_encounter.gd`

### Обязательные интерфейсы

- Каждый мини-босс выдаёт сигнал/событие `reward_granted(id: StringName)` ровно один раз:
  - `kittens`
  - `papy_flowers`
  - `skelberry`
- `LanaEncounter`:
  - три фазы;
  - `on_wave_cleared()`;
  - `advance_song()`;
  - `complete()`;
  - не имеет HP/damage interface и не может получить урон от атаки игрока.
- `WarehouseFlow` должен вести маршрут склада, выдавать награды и собирать второй артефакт `ashtray`.

### Поведение по дизайну

1. Четыре головы котят возвращаются по одной.
2. Награда котят открывает combo до трёх ударов через существующий `AttackController`/`ProgressState`.
3. Papy Flowers открывает air-strong; горизонтальная инерция и splash можно сначала представить контрактом, без отдельной панели оружия.
4. Skelberry открывает зелья и ограниченные заряды.
5. Кирилл Портак спасён в level flow, а не зашит в boss logic.
6. Lana — фоновой performance encounter:
   - три песни/фазы;
   - каждая фаза завершается очисткой волны;
   - арена меняется между песнями;
   - Lana не имеет HP и не принимает урон;
   - после финала возвращаются дым/краска и выдаётся сюжетная награда.
7. После завершения склада собирается `ashtray` ровно один раз.

## Рекомендуемый порядок реализации

1. Написать failing tests для `WarehouseFlow` и мини-боссов.
2. Написать failing tests для `LanaEncounter`, включая невозможность урона.
3. Запустить focused/full runner и зафиксировать RED.
4. Реализовать маленькие data-driven reward contracts.
5. Реализовать `WarehouseFlow` и три mini-boss reward emitters.
6. Реализовать Lana без HP/damage API.
7. Добавить минимальные запускаемые сцены склада/encounters: фон, пол, игрок, камера и текстовая подсказка; не оставлять новые сцены пустыми серыми контейнерами.
8. Подключить интеграционные тесты к `tests/run_tests.gd`.
9. Запустить Godot headless и editor-load check.
10. Восстановить шумовой `project.godot`, если он изменён только автоформатированием.
11. Сделать commit и push после зелёного среза.

## Границы Task 5

- Не создавать отдельный UI-инвентарь татуировок.
- Не добавлять новую схему управления.
- Не превращать Lana в обычного врага с HP.
- Не переписывать Task 1–4.
- Не делать финальную графику; placeholder-геометрия допустима.
- Сохранять единый `ProgressState` и существующие `AttackController` gates.

## Критерий закрытия Task 5

Task 5 можно считать закрытым после того, как одновременно выполнено всё ниже:

- full headless suite зелёный;
- rewards мини-боссов выдаются ровно один раз;
- combo, air-strong и potion открываются в правильной последовательности;
- Lana проходит три волны/песни без HP и damage path;
- `ashtray` выдаётся ровно один раз;
- складские сцены загружаются и имеют минимальный визуальный playable shell;
- рабочее дерево чистое;
- commit и push выполнены.
