# US6 playtest checklist

## Release gate

- [ ] Complete the main run: Moscow → warehouse → Ryazan → Danang → finale.
- [ ] Confirm the finale requires all four artifacts and explicit confirmation.
- [ ] Confirm the ritual leaves Yulia alive, clears dangerous mutation, and preserves harmless tattoo motion.
- [ ] Confirm the epilogue is unavailable before `main_run_completed`.
- [ ] Confirm the epilogue order: Watchman, Portak, Lisa, Shizik and followers, Sanboy, then the warm Yulia/Watchman frame.
- [ ] Confirm the mandatory video-message placeholder opens after the epilogue and can be opened repeatedly.
- [ ] Confirm the ashtray opens the memory menu only after the main run.
- [ ] Replay each memory: `moscow`, `warehouse`, `ryazan`, `danang`, `finale`.
- [ ] Confirm a replay starts with fresh progression: no combo, potion charges, abilities, or artifacts from the main run.
- [ ] Confirm replay does not change the main completion state or main `ProgressState`.
- [ ] Confirm an unknown replay ID is rejected and any valid replay can be started again.

## Performance budget

The deterministic `PerformanceProbe` uses a conservative desktop/portable target budget:

- peak frame time: **≤ 33.34 ms** (30 FPS floor);
- peak active enemies: **≤ 32**;
- peak particles: **≤ 400**;
- draw calls: **≤ 250**.

The headless test injects bounded samples instead of asserting unstable CI FPS. On a target device, run a 10-minute traversal including a boss arena and record the probe result. If a budget fails, reduce particles, background layers, or decorative transitions before changing the 2D format.

## Manual platform checks

- [ ] Desktop keyboard: movement, jump, dodge, attack, strong attack, interact, potion.
- [ ] Gamepad/controller: same actions and menu focus.
- [ ] Resize/windowed mode: no critical HUD or menu clipping.
- [ ] Load `scenes/epilogue/epilogue.tscn` and `scenes/ui/memory_menu.tscn` in the editor.
- [ ] Verify the placeholder is replaced by the real personal video before production release.

## Known content status

No real media file is committed in Task 10. The video contract is implemented with a replaceable placeholder state and repeatable launch tracking; this is not the finished personal video.
