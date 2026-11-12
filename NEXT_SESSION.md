# US6 — handoff для следующей сессии

## Текущее состояние

- Проект: `E:\US6`
- Godot: `E:\Godot\Godot_v4.7.2-stable_win64.exe`
- Ветка: `main`
- Remote: `origin` → `https://github.com/skivelll/US6-THE-CIGAR-FELL.git`
- Рабочее дерево на момент handoff: чистое
- Последний коммит: `bfdde1c Task 2: player controller, checkpoint manager, test room`
- `main` и `origin/main` синхронизированы

## Уже сделано

### Task 1
- `ProgressState`
- headless test runner
- базовая main-сцена
- README
- recursion guard в `.superpowers/recursion_guard.ps1`

### Task 2
- `PlayerController` на `CharacterBody2D`
- placeholder-вид персонажа: простые цветные геометрические элементы
- движение, бег, прыжок, dodge
- HP, урон, смерть, respawn
- checkpoint manager
- тестовая комната
- unit-тесты
- InputMap

Финальный внешний вид персонажей пока намеренно НЕ делается.

## Важное предупреждение

В истории есть несколько повторных коммитов Task 2 из-за обрывов провайдера:

- `dd6dc17`
- `fc227ca`
- `8e7821f`
- `bfdde1c`

Не реализовывать Task 2 повторно и не делать reset/rebase без явного решения пользователя.

## Следующий шаг

Task 3: боевое ядро:

- `AttackController`
- `HealthComponent`
- hitbox/hurtbox
- базовые normal/strong атаки
- cooldown сильной атаки
- заготовка combo/air-strong через ProgressState
- EncounterController с фазами
- headless-тесты

## Правила новой сессии

1. Не перечитывать полностью `docs/superpowers/`.
2. Сначала выполнить только:
   ```powershell
   git status --short --branch
   git log --oneline -3
   ```
3. Проверить Task 2 одной командой Godot.
4. Не запускать `task-start`: локальный SDD-скрипт отсутствует и вызывает интерактивные/повторные сбои.
5. Не запускать несколько subagent-ов для одной задачи.
6. Не передавать subagent-у полный план и большие файлы; передавать только нужный контракт Task 3.
7. После каждого завершённого среза: тест → commit → push → краткий отчёт.
8. При `unknown finish reason` не повторять длинный prompt. Начать новую сессию и использовать этот файл.
