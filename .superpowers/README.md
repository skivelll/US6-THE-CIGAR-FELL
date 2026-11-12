# Agent workspace

This directory is reserved for local execution state.

## Recursion guard

Before running a nested helper or automation script, run:

```powershell
. .\.superpowers\recursion_guard.ps1 -Action "task-name"
```

The guard uses `US6_AGENT_DEPTH` and stops loudly at depth 8. Do not rerun a failed helper blindly; inspect its error and continue with the direct project command.

Project documentation and implementation plans remain in `docs/superpowers/`.
