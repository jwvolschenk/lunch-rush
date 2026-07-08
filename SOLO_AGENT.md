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
      ARCHIVE done items → REFLECT to find new work → refill backlog → repeat

- **EXECUTE** (most cycles): the orchestrator picks the next `- [ ]` task from
  backlog.md and asks you to implement it. Churn through ALL pending tasks first.
- **REFLECT** (only when backlog is empty): survey the project vs. the goal and
  propose the next round of tasks to refill the backlog. The orchestrator archives
  completed items into `backlog-history/` before calling you.
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
| `reflections.md` | what's been tried, what worked/failed | read second — avoid repeating failures |
| `backlog.md` | the task list | REFLECT adds to it; EXECUTE pulls the next `- [ ]` task |
| `skills/INDEX.md` | reusable snippets/tests the loop produced | consult before implementing |

## Directives (human steering)

`directives.md` contains guidance queued by a human mid-loop. Each has a status:
`pending` → `acknowledged` → `done`.

- **Read it every session.** Pending (`status: pending`) directives take priority
  over backlog tasks — address them first.
- When you start working on a directive, edit its `status:` line to `acknowledged`.
- When you complete it, edit the `status:` line to `done`.
- The human uses these to steer you: "use JWT not sessions", "focus on tests next",
  "this bug is critical", etc.

## Rules (non-negotiable)

1. **Fresh context.** Never assume state from a prior session — re-read the files.
2. **Backlog-first.** Don't propose new work while backlog items are pending.
   Churn through the existing backlog; reflection only happens when it's clear.
3. **Mark tasks done.** When you complete a task (or find it's already done),
   edit its backlog.md line from `- [ ]` to `- [x]`. This is required — it's
   how progress is tracked.
4. **Directives are priority.** Address pending directives before other backlog work.
5. **Stay in scope.** EXECUTE does ONE task. Don't refactor unrelated code.
6. **Never touch `main` / run git unless told.** The orchestrator manages git.
7. **Verify your own work.** If there's no orchestrator gate, run the project's
   build/test/lint yourself before stopping. Don't claim success you didn't check.
8. **Be honest.** If a task is blocked, invalid, or you can't complete it — say so
   clearly in your final message. Don't pretend success.
9. **Reverts can happen.** If an orchestrator gate fails, your work may be reverted.
   That's normal — read reflections.md to learn why.

## Stop signal

When you finish your assigned phase/task, end your final message with a line
starting with `DONE:` followed by a one-line summary, e.g.:

    DONE: Scaffolded the Godot project with base scene + main script.

Then stop. The orchestrator detects completion from this. Do not ask questions
or wait for further input — this runs unattended.
