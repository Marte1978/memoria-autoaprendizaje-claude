---
name: context-optimizer
description: Compresses and reorganizes the active context window when it gets too large. Audits what is consuming space, summarizes resolved work, archives completed tasks, and reloads only what is needed for the current task.
---

# Skill: /context-optimizer

## Purpose

As a Claude Code session grows, the context window accumulates noise: full file reads, long error logs, resolved debugging threads, repeated explanations, and completed task discussions. This noise crowds out the space needed for current work and makes Claude's responses less focused. This skill systematically compresses that noise without losing anything important.

## When to Activate

- You are **approaching the context limit** and need to continue working
- The session **feels slow or unfocused** — Claude is repeating itself or losing track of recent decisions
- **Before starting a complex task** that will require a large, clean context window
- After a **long debugging session** where many files were read and errors were logged
- Before running `/compact` — optimizing first means compact preserves higher-quality information
- After completing a distinct phase of work before starting the next

---

## The 5-Step Process

### Step 1 — Audit
Identify what is currently taking up context. Look for:

- **Full file reads** — entire files read when only a few functions were relevant
- **Long error logs** — stack traces and build output that have already been resolved
- **Repeated information** — the same function or config explained multiple times across messages
- **Resolved task threads** — discussion about a bug that is now fixed and committed
- **MCP output dumps** — large JSON responses from Supabase, Playwright screenshots descriptions, Firecrawl crawl results
- **Back-and-forth iterations** — 10 messages debugging something that is now working

Output: a ranked list of the top 5 context consumers with estimated size.

### Step 2 — Compress
Summarize long outputs into the minimum facts needed to continue working:

- A 200-line stack trace becomes: "Build failed on `src/api/route.ts:45` — missing return type. Fixed by adding `: Promise<Response>`."
- A 50-message debugging thread becomes: "Auth redirect bug. Root cause: middleware was running before session hydration. Fix: moved session check to after `await getSession()`. Committed in abc1234."
- A full file read becomes: "Read `src/lib/db.ts` — exports `createClient()`, `getUser(id)`, `updateUser(id, data)`. Connection via env var `DATABASE_URL`."

**Rule:** The compression must contain enough information to reproduce the decision or avoid the error. If it cannot, keep more detail.

### Step 3 — Archive
Move resolved work out of active context and into persistent memory files:

- Create or update a memory file (e.g., `.claude/memory/session-[date].md`) with the compressed summaries
- Record all decisions made: architectural choices, rejected approaches, agreed conventions
- Record all bugs fixed: what failed, what the root cause was, what the fix was
- Record all completed tasks: what was built, where it lives, what tests cover it

**Format for archived entries:**
```markdown
### [timestamp] [Task name]
- **What:** [One sentence description]
- **Decision/Fix:** [The key fact to preserve]
- **Location:** [File path or commit hash if relevant]
```

Once archived, reference the memory file by path. Do not re-paste the content.

### Step 4 — Reload
Keep only what is needed for the task immediately ahead:

- The current task description and its acceptance criteria
- Files that will be modified in the next phase (paths only, not content — read them fresh when needed)
- Active errors that have not yet been resolved
- Decisions made this session that affect the current task
- Any in-progress state (e.g., migration half-applied, feature half-built)

Everything else is either archived (Step 3) or can be re-read on demand. The active context after reload should feel minimal and purposeful.

### Step 5 — Confirm
Report what was recovered:

```
Context Optimizer — Results
---------------------------
Audited:    [N] major context consumers identified
Compressed: [N] long outputs summarized (saved ~X% context)
Archived:   [N] resolved tasks moved to memory
Reloaded:   [N] items kept for current task
Status:     Context reduced from ~X% to ~Y%
Memory:     Saved to [file path]
```

---

## Rules — What Must Never Be Discarded

These items must survive any optimization pass:

- **Unfinished tasks** — anything not yet committed, deployed, or explicitly closed
- **Unfixed errors** — active bugs, failing tests, broken builds
- **Error fixes from this session** — knowing what was tried and failed prevents re-trying it
- **All decisions made** — architectural choices, library selections, naming conventions agreed upon
- **Environment context** — env vars confirmed, credentials used, ports configured
- **User corrections** — if the user corrected Claude's approach, that correction must be preserved

When in doubt, archive rather than discard.

---

## Commands

### `/context-optimizer`
Runs the full 5-step optimization process: audit, compress, archive, reload, confirm.

**Typical duration:** 2–4 minutes for a well-established session.

**Best used:** Before starting a new phase of work, after a long debugging session, or before running `/compact`.

### `/context-optimizer --audit`
Analysis only. Runs Step 1 (Audit) and reports findings without making any changes.

**Output includes:**
- Top 5 context consumers ranked by estimated size
- Recommendation: compress, archive, or keep for each item
- Estimated context that could be recovered if full optimization is run

**Best used:** When you want to understand the state of the context before deciding whether to optimize.

---

## Integration Notes

- Run `/context-optimizer --audit` first if you are unsure whether optimization is needed
- Pair with `/token-saver` to identify when to optimize and what the priority actions are
- Pair with `/pipeline-state` to checkpoint pipeline progress before archiving the session context
- After running `/context-optimizer`, run `/compact` to further compress what remains in the conversation history
- Memory files created during archiving follow the same format as `/auto-learn` output and can be reviewed or edited manually
