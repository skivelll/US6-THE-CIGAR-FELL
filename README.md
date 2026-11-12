# US6: Сигара упала (The Cigar Fell)

A 2D story-driven action-adventure game built in Godot 4.7. A personal gift game about Yulia, who journeys through absurd mutated territories to collect four giant artifacts and light the cigar that will save the world.

## Story

A cigar falls in Moscow. Mutation spreads. The protagonist must collect four giant mutated artifacts — a cigar cutter, an ashtray, a heart-generator lighter, and a mouthpiece — to smoke the cigar and save the world.

## Tech Stack

- **Engine:** Godot 4.7.2
- **Language:** GDScript 2.0
- **Format:** 2D (CharacterBody2D)
- **Tests:** Headless SceneTree runner via `godot --headless`

## Project Structure

```
scripts/          Game logic (ProgressState, player controller, enemies, etc.)
tests/            Headless test runners
scenes/           .tscn scene files
docs/superpowers/ Design spec and implementation plan
```

## Running Tests

```powershell
E:\Godot\Godot_v4.7.2-stable_win64.exe --headless --path E:\US6 --script tests/test_progress_state.gd
```

Exit code 0 = all tests passed, 1 = failures.

## Development

See `docs/superpowers/specs/2026-11-12-us6-master-design.md` for the full design document and `docs/superpowers/plans/2026-11-12-us6-implementation.md` for the task-by-task implementation plan.
