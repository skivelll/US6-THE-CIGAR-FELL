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
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path E:\US6 --script res://tests/run_tests.gd
```

Exit code 0 = all tests passed, 1 = failures. The suite covers the post-finale epilogue, mandatory repeatable video-message launch contract, memory replays, replay isolation, and performance schema.

## Post-finale content

After `main_run_completed`, the deterministic epilogue ends on a warm Yulia/Watchman frame. The ashtray memory menu exposes replays for Moscow, warehouse, Ryazan, Danang, and the finale. Every replay creates a fresh `ProgressState`; it is not New Game+ and cannot alter the completed main run.

The video-message path currently uses a replaceable presentation placeholder. It is intentionally not described as the finished personal video: the real media asset still needs to be supplied and encoded for the target build.

Performance budgets used by the deterministic probe are documented in `docs/qa/us6-playtest-checklist.md`.

## Development

See `docs/superpowers/specs/2026-11-12-us6-master-design.md` for the full design document and `docs/superpowers/plans/2026-11-12-us6-implementation.md` for the task-by-task implementation plan.
