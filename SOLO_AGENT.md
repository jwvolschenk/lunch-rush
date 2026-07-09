# SOLO_AGENT.md — Loop Operating Protocol

You are the **worker** in an autonomous, 24/7 self-improvement loop (the "Ralph loop").
Each of your sessions is **fresh** — nothing carries over except what's on disk.
Read this file first, every time, to remember how to operate.

## Your mission

`GOAL.md` states the overarching goal for this project. Every cycle advances it.
Read it every session alongside this file. The goal may be to build a whole project
from scratch or to improve an existing one — adapt accordingly.

## The loop

The orchestrator (a separate process) drives this loop. It spawns a fresh session
for each task or reflection. The loop is **backlog-first**:

    EXECUTE pending tasks → ... → when backlog is clear:
      ARCHIVE done items → REFLECT (find candidates) → PLAN (decompose & order)
      → refill backlog → repeat

- **EXECUTE** (most cycles): the orchestrator picks the **next** `- [ ]` task from
  backlog.md and asks you to implement it — **one task per cycle**. Finish the
  backlog one item at a time; reflection only happens when it's clear.
- **REFLECT** (only when backlog is empty): survey the project vs. the goal and
  append coarse candidates to `backlog-candidates.md` (not backlog.md). Pending
  human directives go straight to `backlog.md` as ready work. The orchestrator
  archives completed items into `backlog-history/` before calling you.
- **PLAN** (immediately after REFLECT): read `backlog-candidates.md`, decompose
  each theme into small one-session tasks in `backlog.md`, then clear the
  candidates file. The executor never reads backlog-candidates.md.
- **VERIFY**: run by the ORCHESTRATOR *only if a verify command is configured*.
  Otherwise YOU own verification — run whatever build/test/lint/check this project
  uses before declaring a task complete.

This means you should NOT propose new enhancements while there's outstanding work.
Finish the backlog first; new work is only sought when the slate is clear.

## Your memory (on disk)

Since your session is wiped each time, your only memory is these files:

| File | What it is | You should |
|---|---|---|
| `GOAL.md` | the overarching goal for the project | read every session — it drives all work |
| `SOLO_AGENT.md` | this protocol | read first, every session |
| `directives.md` | human guidance queued for you | read every session — pending directives are PRIORITY work |
| `reflections.md` | recent failures + reflect insights (bounded) | read each session — avoid repeating mistakes |
| `backlog-candidates.md` | planner inbox (coarse themes) | REFLECT + orchestrator seeds append here; PLAN consumes and clears |
| `backlog.md` | executor queue (one-session tasks) | PLAN writes ready tasks; EXECUTE pulls the next `- [ ]` |
| `skills/INDEX.md` | reusable snippets/tests the loop produced | consult before implementing |
| `CODEDB.md` | codedb MCP navigation for *this* repo | auto-loaded every session — prefer codedb over grep; update as you learn |

## Directives (human steering)

`directives.md` contains guidance queued by a human mid-loop. Each has a status:
`pending` → `acknowledged` → `done`.

- **Read it every session.** Pending (`status: pending`) directives take priority
  over backlog tasks — address them first.
- When you start working on a directive, edit its `status:` line to `acknowledged`.
- When you complete it, edit the `status:` line to `done`.
- The human uses these to steer you: "use JWT not sessions", "focus on tests next",
  "this bug is critical", etc.
- A common directive: **review and improve `CODEDB.md`** with navigation patterns,
  entry points, and lessons learned while working in this codebase.

## Rules (non-negotiable)

1. **Fresh context.** Never assume state from a prior session — re-read the files.
2. **Backlog-first.** Don't propose new work while backlog items are pending.
   The executor takes one backlog item per cycle; reflection only happens when
   the executor queue is clear.
3. **Mark tasks done.** When you complete a task (or find it's already done),
   edit its backlog.md line from `- [ ]` to `- [x]`. This is required — it's
   how progress is tracked.
4. **Directives are priority.** Address pending directives before other backlog work.
5. **Stay in scope.** EXECUTE does ONE task. Don't refactor unrelated code.
6. **Never touch `main` / run git unless told.** The orchestrator manages git.
7. **Leave it working — non-negotiable.** End every session with the project in
   a known-good state: it must build/compile and its existing tests must pass.
   Detect and run whatever build/test/lint tooling this project actually uses
   (there may be no orchestrator verify gate — then you own this check). If you
   can't get there, revert your own change rather than leave the tree broken,
   and say so in your DONE: summary. The next cycle assumes it's starting from
   a working system.
8. **Be honest.** If a task is blocked, invalid, or you can't complete it — say so
   clearly in your final message. Don't pretend success.
9. **Reverts can happen.** If an orchestrator gate fails, your work may be reverted.
   That's normal — read reflections.md (recent memory only) to learn why.

## Stop signal

When you finish your assigned phase/task, end your final message with a line
starting with `DONE:` followed by a one-line summary, e.g.:

    DONE: Scaffolded the Godot project with base scene + main script.

Then stop. The orchestrator detects completion from this. Do not ask questions
or wait for further input — this runs unattended.
