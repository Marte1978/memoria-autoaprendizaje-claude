---
name: pipeline-state
description: Manages checkpoint state for long multi-phase pipelines. Saves progress after each completed phase so that on failure, the pipeline resumes from the last checkpoint instead of restarting from scratch.
---

# Skill: /pipeline-state

## Purpose

Long pipelines — deployments, site builds, database migrations, data processing jobs — frequently fail midway. Without checkpointing, the only recovery option is to restart from the beginning, re-running completed work, risking side effects from re-applying already-applied changes, and wasting time.

This skill creates lightweight JSON checkpoint files that track the state of each phase in a pipeline. On failure, it reads the checkpoint, identifies where the pipeline stopped, skips everything already completed, and resumes from the failed phase.

---

## Problem It Solves

**Without pipeline-state:**
- Pipeline has 8 phases. Phase 6 fails.
- You restart. Phases 1–5 run again. Some are idempotent; some are not.
- Phase 3 creates a database table that now already exists — error.
- Phase 1 uploads files that now exist — duplicate or overwrite.
- You spend 20 minutes re-doing work that succeeded the first time.

**With pipeline-state:**
- Pipeline has 8 phases. Phase 6 fails.
- You run `/pipeline-state resume my-pipeline`.
- Phases 1–5 are read as `completed` and skipped.
- Pipeline restarts at Phase 6 with full context of what phases 1–5 produced.
- You are back up and running in under a minute.

---

## How It Works

### Checkpoint Storage

Pipeline state is stored in `.pipeline-state/[pipeline-name].json` relative to the project root. This directory should be added to `.gitignore` unless you want to commit pipeline state for team visibility.

The checkpoint file is written after each phase completes. If Claude Code or the process crashes mid-phase, the phase is treated as `in_progress` (not completed) and will be re-run on resume.

### Phase Status Lifecycle

```
pending → in_progress → completed
                     ↘ failed
```

- `pending` — phase has not started
- `in_progress` — phase started but no completion checkpoint written yet
- `completed` — phase finished successfully; checkpoint written
- `failed` — phase threw an error; error message and timestamp recorded

### Resume Logic

On `/pipeline-state resume [name]`:
1. Read the checkpoint file
2. Find the first phase that is NOT `completed`
3. Skip all `completed` phases
4. If the first non-completed phase is `failed`, clear its status to `pending` before running
5. Execute from that phase forward, writing checkpoints after each success

---

## Checkpoint File Format

**Location:** `.pipeline-state/[pipeline-name].json`

**Schema:**

```json
{
  "pipeline": "string — unique name for this pipeline run",
  "created_at": "ISO 8601 timestamp",
  "updated_at": "ISO 8601 timestamp",
  "status": "pending | in_progress | completed | failed",
  "phases": [
    {
      "id": "string — short unique identifier (e.g., 'db-migrate', 'build', 'upload-assets')",
      "name": "string — human-readable phase name",
      "status": "pending | in_progress | completed | failed",
      "started_at": "ISO 8601 timestamp | null",
      "completed_at": "ISO 8601 timestamp | null",
      "output_summary": "string | null — key facts produced by this phase (e.g., 'Created 3 tables: users, posts, sessions')",
      "error": "string | null — error message if status is failed",
      "metadata": {}
    }
  ],
  "context": {
    "description": "string — what this pipeline does",
    "triggered_by": "string — manual | schedule | event",
    "environment": "string — development | staging | production"
  }
}
```

**Example:**

```json
{
  "pipeline": "site-deploy-acme-2024-01-15",
  "created_at": "2024-01-15T14:22:00Z",
  "updated_at": "2024-01-15T14:35:47Z",
  "status": "in_progress",
  "phases": [
    {
      "id": "install-deps",
      "name": "Install dependencies",
      "status": "completed",
      "started_at": "2024-01-15T14:22:01Z",
      "completed_at": "2024-01-15T14:22:45Z",
      "output_summary": "npm ci completed — 847 packages installed",
      "error": null,
      "metadata": {}
    },
    {
      "id": "db-migrate",
      "name": "Run database migrations",
      "status": "completed",
      "started_at": "2024-01-15T14:22:46Z",
      "completed_at": "2024-01-15T14:23:10Z",
      "output_summary": "4 migrations applied: 001_users, 002_posts, 003_sessions, 004_audit_log",
      "error": null,
      "metadata": { "migrations_applied": 4 }
    },
    {
      "id": "build",
      "name": "Build production bundle",
      "status": "failed",
      "started_at": "2024-01-15T14:23:11Z",
      "completed_at": null,
      "output_summary": null,
      "error": "Type error in src/app/page.tsx:23 — Property 'title' does not exist on type 'Post'",
      "metadata": {}
    },
    {
      "id": "deploy",
      "name": "Deploy to production",
      "status": "pending",
      "started_at": null,
      "completed_at": null,
      "output_summary": null,
      "error": null,
      "metadata": {}
    }
  ],
  "context": {
    "description": "Full deployment pipeline for Acme Corp site",
    "triggered_by": "manual",
    "environment": "production"
  }
}
```

---

## Commands

### `/pipeline-state init [name]`
Initialize a new pipeline checkpoint file. Creates `.pipeline-state/[name].json` with all phases set to `pending`.

**Usage:**
```
/pipeline-state init site-deploy-acme
/pipeline-state init db-migration-v2
/pipeline-state init data-import-january
```

You will be prompted to define the pipeline phases (ids, names) and the pipeline description. Alternatively, pass a phases list directly in your prompt.

### `/pipeline-state checkpoint [phase-id]`
Mark a phase as `completed` and write its output summary to the checkpoint file. Call this immediately after each phase succeeds.

**Usage:**
```
/pipeline-state checkpoint install-deps
/pipeline-state checkpoint db-migrate "4 migrations applied: 001_users, 002_posts, 003_sessions, 004_audit_log"
```

The optional second argument is the output summary — a one-line description of what the phase produced. Include it to make resume and status output more useful.

### `/pipeline-state resume [name]`
Read the checkpoint file and resume the pipeline from the first non-completed phase.

**Usage:**
```
/pipeline-state resume site-deploy-acme
```

**Behavior:**
- Reads `.pipeline-state/[name].json`
- Reports which phases are already completed (skipping them)
- Identifies the resume point
- Shows the error from the failed phase (if any) so you can fix it before retrying
- Begins execution from the resume point

### `/pipeline-state status [name]`
Display the current state of a pipeline without taking any action. Shows each phase, its status, timestamps, and output summaries.

**Usage:**
```
/pipeline-state status site-deploy-acme
```

**Example output:**
```
Pipeline: site-deploy-acme
Status: in_progress (phase 3 of 4)
Updated: 2024-01-15 14:35:47

  [✓] install-deps       Install dependencies         14:22:01 → 14:22:45
  [✓] db-migrate         Run database migrations      14:22:46 → 14:23:10
  [✗] build              Build production bundle      14:23:11 → FAILED
  [ ] deploy             Deploy to production         pending

Last error (build):
  Type error in src/app/page.tsx:23 — Property 'title' does not exist on type 'Post'
```

### `/pipeline-state reset [name]`
Clear all phase statuses back to `pending` and restart the pipeline from the beginning. Use this when you want a clean run after making significant changes that affect already-completed phases.

**Usage:**
```
/pipeline-state reset site-deploy-acme
```

A confirmation prompt is shown before resetting. The original checkpoint file is backed up to `.pipeline-state/[name].backup.json` before the reset.

---

## Integration Guide

### With any multi-phase workflow

Add checkpoint calls around each phase in your pipeline description:

```
PHASE 1: Install dependencies
  → /pipeline-state checkpoint install-deps "npm ci complete"

PHASE 2: Run migrations
  → /pipeline-state checkpoint db-migrate "N migrations applied"

PHASE 3: Build
  → /pipeline-state checkpoint build "Bundle size: X MB"

PHASE 4: Deploy
  → /pipeline-state checkpoint deploy "Live at https://..."
```

### With `/context-optimizer`

Before running `/context-optimizer` or `/clear` in a long pipeline session, run `/pipeline-state checkpoint [current-phase]` to save progress. When you return with a fresh context, run `/pipeline-state status [name]` to reorient and then `resume` to continue.

### With `/token-saver --emergency`

When a Red zone token emergency forces a `/clear`, the checkpoint file on disk persists independently of session context. Your pipeline progress is not lost. After clearing, run `/pipeline-state resume [name]` to reload exactly where you were.

### With deployment pipelines

Pair with the `/deploy` skill. The deploy pipeline naturally maps to pipeline-state phases: pre-flight checks, build, test, upload, cutover, verify.

### With database migrations

Migration pipelines are particularly well-suited to checkpoint tracking because re-running completed migrations causes errors. Checkpointing each migration group and skipping completed ones on resume makes recovery safe.

---

## `.gitignore` Recommendation

For most projects, add the following to `.gitignore`:

```
.pipeline-state/
```

If you want to share pipeline state with teammates or preserve it across machines, omit this entry and commit the state files. They are plain JSON and safe to commit.
