# US6 — handoff для Task 10

## Цель следующего чата

Продолжить разработку US6 с **Task 10: эпилог, обязательное видеопослание, меню воспоминаний и platform verification**.

Task 9 завершён и опубликован в `origin/main`: основной конфликт закрыт, ритуал завершён без смерти Юли, опасная мутация очищается, безвредное движение татуировок сохраняется. Task 10 должен добавить постигровой контент и replay-возможности, не ломая основной run.

## Текущее состояние репозитория

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Последний commit: `a01722a Implement Task 9 finale flow and ritual`
- Ожидаемое состояние ветки: `main...origin/main`
- После Task 9 рабочее дерево чистое.
- Godot может автоматически форматировать `project.godot` после editor-load check. Если diff содержит только автоматическое форматирование, выполнить `git restore -- project.godot`.

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
--- RyazanFlow ---
PASS
--- DanangFlow ---
PASS
--- FinaleFlow ---
PASS
=== ALL PASS ===
```

Возможны стандартные Godot warnings о leaked CanvasItem/ObjectDB resources в headless runner. Они должны быть отдельно указаны в отчёте и не заменяют проверку exit code и содержимого тестов.

## Обязательные документы для чтения

Перед планированием и изменениями прочитать:

```text
docs/superpowers/specs/2026-11-12-us6-master-design.md
docs/superpowers/plans/2026-11-12-us6-implementation.md
docs/superpowers/handoffs/2026-11-12-task9-handoff.md
docs/superpowers/handoffs/2026-11-12-task10-handoff.md
```

Также изучить перед реализацией:

```text
scripts/core/progress_state.gd
scripts/finale/finale_flow.gd
scripts/base/base_controller.gd
scripts/base/base_state_view.gd
scenes/levels/base.tscn
scenes/levels/finale.tscn
tests/run_tests.gd
tests/integration/test_finale_flow.gd
README.md
project.godot
```

## Уже реализовано

### Tasks 1–8

- `ProgressState` с abilities/artifacts и serializable snapshot.
- Player/checkpoint foundation.
- Единое боевое ядро и reusable encounter contracts.
- Москва, склад, Lana, Рязань и Дананг.
- Четыре артефакта:
  - `cigar_cutter`;
  - `ashtray`;
  - `lighter_heart`;
  - `mouthpiece`.
- Развивающееся состояние базы.

### Task 9

- `scripts/finale/finale_flow.gd`.
- `scenes/levels/finale.tscn`.
- `scenes/encounters/portak_finale.tscn`.
- `scenes/encounters/watchman_finale.tscn`.
- `scenes/encounters/sanboy_finale.tscn`.
- `tests/integration/test_finale_flow.gd`.
- Финал требует артефакты и explicit confirmation.
- Фазы идут `portak → watchman → sanboy`.
- Санбой появляется только после Смотрителя.
- Лиза и Шизик не входят в финальный roster.
- Ritual state: Юля жива, mutation cleared, harmless tattoos preserved, main run completed.
- Task 10 пока не запускается автоматически.

## Цель Task 10

Реализовать последовательность:

```text
completed main run → epilogue montage → mandatory video message → memory menu
```

Task 10 должен добавить:

- короткий криминально-фильмный эпилог без нового обязательного управления;
- повторяемое личное видеопослание;
- меню воспоминаний через пепельницу;
- replay всех четырёх территорий и финала;
- изоляцию replay-прогресса от основного сохранения;
- performance probe и QA checklist.

## Обязательные файлы

Создать:

- `scenes/epilogue/epilogue.tscn`
- `scripts/epilogue/epilogue_controller.gd`
- `scenes/ui/memory_menu.tscn`
- `scripts/ui/memory_menu.gd`
- `scripts/platform/performance_probe.gd`
- `tests/integration/test_postgame_menu.gd`
- `docs/qa/us6-playtest-checklist.md`

Изменить при необходимости:

- `tests/run_tests.gd`
- `README.md`
- существующие base/finale presentation hooks.

Не добавлять отдельный progression manager или новый инвентарь. Replay должен создавать изолированный `ProgressState`, не мутируя основной run.

## Обязательные контракты

### `EpilogueController`

Минимальный API:

```gdscript
play() -> bool
replay() -> bool
open_video() -> bool
```

Требуемое поведение:

- `play()` доступен только после `main_run_completed`.
- Эпилог проходит в детерминированном порядке.
- Все обязательные сцены представлены хотя бы replaceable still/slide presentation:
  - Смотритель;
  - Портак;
  - Лиза;
  - Шизик и безликие прихвостни;
  - Санбой;
  - Юля и Смотритель в финальном тёплом кадре.
- После завершения эпилога доступно обязательное видеопослание.
- `replay()` повторяет эпилог без дублирования состояния и сигналов.
- `open_video()` можно вызвать повторно.
- Task 10 не должен считать видео просмотренным только из-за проверки доступности файла: проверяется доступность и observable launch state.

Рекомендуемые fields/signals:

```gdscript
epilogue_started
epilogue_completed
epilogue_index
epilogue_slides
video_available
video_opened
video_launch_count
```

Видео может быть presentation placeholder, если реальный media asset ещё не добавлен. Контракт должен позволять заменить placeholder на настоящий файл без переписывания flow.

### `MemoryMenu`

Минимальный API:

```gdscript
replay_level(level_id: StringName) -> bool
available_memories() -> Array[StringName]
```

Требуемые level IDs:

```text
moscow
warehouse
ryazan
danang
finale
```

Требуемое поведение:

- меню открывается после завершённого основного run;
- источник меню — пепельница/послефинальное состояние базы;
- неизвестный level ID отклоняется;
- replay каждого разрешённого уровня создаёт исходное состояние соответствующей территории;
- replay не переносит combo, potion charges, abilities или artifacts из основного run;
- replay не изменяет основной `ProgressState`;
- replay не делает повторный основной run завершённым;
- каждый replay можно запустить повторно.

Рекомендуемые fields/signals:

```gdscript
menu_opened
replay_started(level_id)
replay_progress
main_progress_unchanged
```

## Performance probe

`PerformanceProbe.sample(duration_seconds: float) -> Dictionary` должен возвращать проверяемый словарь минимум с ключами:

```text
duration_seconds
average_frame_time_ms
peak_frame_time_ms
peak_active_enemies
peak_particles
draw_calls
within_budget
```

Для headless-тестов допускается детерминированный injectable sampler или bounded fallback. Не привязывать тесты к нестабильному реальному FPS CI.

Пороговые значения должны быть записаны в `docs/qa/us6-playtest-checklist.md` и объяснены как production budget, а не как случайные assertions.

## Обязательный TDD-порядок

1. Написать failing tests для недоступности эпилога до `main_run_completed`.
2. Добавить failing tests для точного порядка эпилога и финального кадра Юли/Смотрителя.
3. Добавить failing tests для доступности и повторного запуска video message.
4. Добавить failing tests для открытия memory menu только после основного run.
5. Добавить failing tests для replay IDs всех четырёх территорий и финала.
6. Добавить failing tests для изоляции replay `ProgressState` от основного прогресса.
7. Добавить failing tests для unknown replay ID и повторного запуска replay.
8. Добавить failing tests для `PerformanceProbe` schema и budget result.
9. Подключить `test_postgame_menu.gd` к `tests/run_tests.gd`.
10. Запустить focused/full suite и зафиксировать RED до production implementation.
11. Реализовать минимальные `EpilogueController`, `MemoryMenu` и `PerformanceProbe`.
12. Создать presentation `epilogue.tscn` без нового обязательного управления.
13. Создать `memory_menu.tscn`, доступное из post-finale state.
14. Подключить реальный flow после Task 9, не ломая существующий финал.
15. Выполнить полный headless suite.
16. Выполнить editor-load check:

```powershell
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --editor --quit
```

17. Выполнить project checker и smoke-load всех новых сцен.
18. Выполнить performance probe в headless и desktop режимах.
19. Обновить `README.md` и QA checklist.
20. После зелёного рабочего среза создать commit и push в `origin/main`.

## Границы Task 10

- Сохранять существующее управление.
- Использовать существующий `ProgressState` как основной источник состояния.
- Не изменять смысл завершённого основного run.
- Не превращать replay в New Game+.
- Не переносить прогресс основного run в replay.
- Не добавлять новый RPG-инвентарь.
- Не добавлять отдельную систему спутников.
- Не менять уже завершённые территории и боссы без regression test.
- Не требовать ручного строительства или менеджмента базы.
- Не считать placeholder-видео настоящим личным видео в production report; явно отметить его статус.

## Критерий закрытия Task 10

Task 10 можно считать закрытым только если одновременно выполнены все условия:

- полный headless suite зелёный;
- эпилог недоступен до завершения main run;
- порядок эпилога детерминирован и покрыт тестом;
- финальный кадр — Юля и Смотритель;
- обязательное видеопослание доступно и повторно запускается;
- memory menu открывается после финала;
- доступны replay `moscow`, `warehouse`, `ryazan`, `danang`, `finale`;
- replay создаёт изолированный прогресс;
- основной прогресс не меняется после replay;
- unknown replay ID отклоняется;
- performance probe возвращает полный schema и budget result;
- QA checklist создан и содержит ручные проверки;
- новые сцены загружаются;
- editor-load check выполнен;
- project checker не сообщает ошибок;
- `project.godot` не содержит автоматический форматирующий шум;
- commit создан и push выполнен в `origin/main`;
- рабочее дерево чистое.

## Обязательный финальный отчёт

Сообщить:

- какие файлы изменены;
- какие тесты прошли;
- RED и GREEN результаты TDD;
- как проверены порядок эпилога и финальный кадр;
- как проверены video availability и повторный запуск;
- как проверена replay isolation;
- результаты performance probe;
- результат editor-load и project checker;
- commit hash;
- результат `git push`;
- состояние `git status --short --branch`;
- сознательные решения;
- отложенные polish-детали;
- честный статус реального media asset: placeholder или готовое видео.
