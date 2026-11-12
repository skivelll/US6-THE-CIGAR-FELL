# US6 — handoff для Task 8

## Цель следующего чата

Продолжить разработку US6 с **Task 8: Дананг, босс-шприц и сборка полного набора артефактов**.

Task 7 завершён и опубликован: playable Рязань, двухфазный LisaBoss, `lighter_heart`, integration tests и editor-load check.

## Текущее состояние репозитория

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Последний commit перед handoff: `cef3fed Implement Task 7 Ryazan and Lisa boss`
- Ожидаемое состояние ветки: `main...origin/main`
- Рабочее дерево на момент handoff чистое.
- Godot иногда автоматически форматирует `project.godot` после editor-load check. Если diff содержит только форматирование, выполнить `git restore -- project.godot` и не коммитить этот шум.

## Обязательная проверка перед изменениями

Сначала выполнить именно эти команды:

```powershell
cd E:\US6
git status --short --branch
git log --oneline -5
git diff -- project.godot
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --script res://tests/run_tests.gd
```

Ожидаемый baseline после Task 7:

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
=== ALL PASS ===
```

## Обязательные документы для чтения

Перед планированием и изменениями прочитать:

```text
docs/superpowers/specs/2026-11-12-us6-master-design.md
docs/superpowers/plans/2026-11-12-us6-implementation.md
docs/superpowers/handoffs/2026-11-12-task7-handoff.md
docs/superpowers/handoffs/2026-11-12-task8-handoff.md
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
- Playable Moscow scenes и `tests/integration/test_moscow_flow.gd`.

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
- `tests/unit/test_base_state_view.gd`.
- `BaseStateView` строит состояния только из артефактов `ProgressState`.
- `BaseController.begin_finale()` требует все четыре артефакта и явное `confirm_finale()`.
- `BaseController.REQUIRED_ARTIFACTS` уже содержит:
  - `cigar_cutter`
  - `ashtray`
  - `lighter_heart`
  - `mouthpiece`

### Task 7 — Ryazan/Lisa

- `scripts/levels/ryazan_flow.gd`.
- `scripts/encounters/lisa_boss.gd`.
- `scenes/levels/ryazan.tscn` и дочерние сцены.
- `scenes/encounters/lisa_boss.tscn`.
- `tests/integration/test_ryazan_flow.gd` подключён к runner.
- Маршрут: `bridge → attic → roof → zazhigalka`.
- LisaBoss имеет ровно `phase_lisa` и `phase_system`.
- `break_crown()` идемпотентен.
- Lisa отсутствует в roster второй фазы.
- `lighter_heart` выдаётся через `ProgressState` ровно один раз.

## Task 8 — цель

Реализовать Дананг как короткую линейную playable-территорию, спасти Кирилла Шизика от гигантского шприца, создать из корпуса шприца `mouthpiece` и довести прогресс до четырёх артефактов.

Task 8 не должен запускать финал. Финал относится к Task 9.

## Обязательные плановые файлы

Создать:

- `scenes/levels/danang.tscn`
- `scenes/encounters/syringe_boss.tscn`
- `scripts/levels/danang_flow.gd`
- `scripts/encounters/syringe_boss.gd`
- `tests/integration/test_danang_flow.gd`

Изменить только при необходимости:

- `scenes/levels/base.tscn`
- `tests/run_tests.gd`

Дополнительные файлы допустимы только если они дают ясный публичный контракт или являются частью playable scene. Не создавать отдельную систему инвентаря, менеджмент базы или новое боевое ядро.

## Сюжетный и геймплейный scope

Дананг — место, связанное с мечтой Юли и Смотрителя о переезде. Юля сначала видит последствия системы Шизика, но не встречается с ним лично до сюжетного момента после босса.

Использовать безопасные абсурдные визуальные маркеры:

- безликие прихвостни;
- безопасное развлекательное/бывшее преступное заведение;
- гигантские таблетки;
- пакетики с белым веществом;
- листья каннабиса и другие стилизованные образы.

Не добавлять употребление, объяснение веществ или реалистичный наркотический сюжет.

Pre-boss маршрут должен переиспользовать существующие возможности Юли:

- normal attack;
- strong attack;
- combo;
- air-strong;
- dodge;
- potion;
- существующие враги и hazard-паттерны.

Новая обязательная схема управления не нужна.

## Обязательные контракты `DanangFlow`

Рекомендуемый минимальный контракт:

```gdscript
enter_room(room: StringName) -> bool
complete_syringe_boss(boss: RefCounted) -> void
complete_level() -> void
```

Требуемое поведение:

- маршрут Дананга принимается только в определённом порядке;
- личная встреча с Шизиком не происходит до победы над боссом;
- победа над SyringeBoss является условием завершения уровня;
- `complete_level()` выдаёт `mouthpiece` через единый `ProgressState` ровно один раз;
- flow отмечает спасённого Шизика;
- flow отмечает появление Шизика и безымянных прихвостней на базе;
- flow меняет presentation state удалённого безопасного заведения;
- повторный `complete_level()` не дублирует артефакт и состояние;
- flow не меняет unrelated abilities или артефакты.

Имена внутренних полей можно выбрать свободно, но observable behavior должен быть покрыт integration tests.

## Обязательные контракты `SyringeBoss`

Минимально необходимо предоставить:

- читаемые attack telegraphs;
- acceleration curve или наблюдаемое постепенное ускорение паттерна;
- `cut_into_mouthpiece() -> bool`;
- сигнал/observable событие `defeated`, испускаемое ровно один раз.

Рекомендуемый минимальный API:

```gdscript
start() -> void
attack_telegraph(attack_id: StringName) -> bool
advance_attack() -> bool
cut_into_mouthpiece() -> bool
is_defeated() -> bool
```

Требуемое поведение:

- босс не считается побеждённым до выполнения условия его боевой фазы;
- атаки имеют читаемую подготовку;
- паттерн ускоряется наблюдаемым и детерминированным образом;
- `cut_into_mouthpiece()` работает ровно один раз после победы;
- повторный `cut_into_mouthpiece()` не создаёт вторую награду и не меняет состояние;
- `defeated` не дублируется;
- отдельной третьей фазы не создавать, если она не нужна для контракта Task 8.

Не создавай параллельное HP/combat ядро, если существующий `HealthComponent`/encounter contract способен покрыть проверяемое поведение.

## Обязательный TDD-порядок

1. Написать failing integration tests для порядка маршрута Дананга.
2. Добавить failing test, что до встречи с Шизиком нельзя завершить его спасение/личную встречу.
3. Добавить failing tests для initial SyringeBoss state и читаемого telegraph contract.
4. Добавить failing test постепенного acceleration curve.
5. Добавить failing tests победы над шприцем, `cut_into_mouthpiece()` и однократного `defeated`.
6. Добавить failing tests для `mouthpiece`, спасения Шизика, base presentation state и четырёх артефактов.
7. Подключить `test_danang_flow.gd` к `tests/run_tests.gd`.
8. Запустить focused/full suite и зафиксировать RED до production implementation.
9. Реализовать минимальные `SyringeBoss` и `DanangFlow`.
10. Создать playable `danang.tscn` с фоном, полом, игроком, камерой, подсказкой управления и короткими читаемыми аренами.
11. Создать `syringe_boss.tscn` с визуально читаемой ареной, телеграфами и стилизованным силуэтом шприца.
12. Подключить post-boss presentation: Шизик отдаёт первый самостоятельный приказ, Шизик и безымянные прихвостни отправляются на базу.
13. Запустить полный headless suite.
14. Выполнить editor-load check:

```powershell
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --editor --quit
```

15. Проверить новые сцены через project checker и smoke-load.
16. Если `project.godot` изменён только автоматическим форматированием Godot, восстановить его:

```powershell
git restore -- project.godot
```

17. После зелёного рабочего среза сделать commit, push и краткий отчёт.

## Границы Task 8

- Не переписывать Task 1–7.
- Использовать существующий `ProgressState`.
- Использовать существующие player/combat contracts.
- Не добавлять новую схему управления.
- Не добавлять отдельный RPG-инвентарь или инвентарь татуировок.
- Не добавлять ручное строительство или менеджмент базы.
- Не запускать финальный бой, ритуал или эпилог.
- Не добавлять третью фазу финального/локального босса без контрактной необходимости.
- Не делать Дананг реалистичной историей об употреблении веществ.
- Не превращать Дананг в открытый город.
- Не требовать свободного пост-боссового исследования Дананга.
- Не добавлять полноценную систему спутников.
- Состояние базы должно следовать за прогрессом, а не создаваться вручную игроком.

## Критерий закрытия Task 8

Task 8 можно считать закрытым только если одновременно выполнены все условия:

- полный headless suite зелёный;
- маршрут Дананга покрыт integration tests;
- до босса нет личной встречи с Шизиком;
- SyringeBoss имеет читаемые telegraphs;
- acceleration curve покрыта тестом;
- `cut_into_mouthpiece()` работает и идемпотентен;
- `defeated` наблюдаем и испускается ровно один раз;
- `mouthpiece` выдаётся через `ProgressState` ровно один раз;
- Шизик и безымянные прихвостни отмечены как прибывшие на базу;
- удалённое безопасное заведение отражено в presentation state;
- все четыре артефакта доступны после Task 8;
- playable `danang.tscn` и `syringe_boss.tscn` загружаются;
- editor-load check выполнен;
- рабочее дерево чистое;
- commit создан и push выполнен в `origin/main`.

## Обязательный финальный отчёт нового чата

Сообщить:

- какие файлы изменены;
- какие тесты прошли;
- RED и GREEN результаты TDD;
- как проверены telegraphs и acceleration curve;
- commit hash;
- результат `git push`;
- состояние `git status --short --branch`;
- сознательные решения;
- отложенные polish-детали.
