---
name: token-saver
description: Audits and optimizes token usage in Claude Code sessions. Run when context feels heavy, before /compact, or proactively to keep sessions efficient and fast.
---

# Skill: /token-saver

## Purpose

Token usage in Claude Code sessions compounds fast. Each connected MCP adds ~17,600 tokens per message. Pasting full files, leaving resolved tasks in context, and ignoring runaway loops all drain your budget silently. This skill audits your current session and applies targeted cleanup to recover capacity.

## When to Use

- Session has exceeded **40% context** (Yellow zone — act now, not later)
- More than **30 messages** have been exchanged in the session
- Before running `/compact` to maximize what compact preserves
- Before starting a complex multi-step task that will need the full window
- Session feels "slow" or responses feel repetitive or confused

---

## Traffic Light System

### Green — 0–40% context
**Status:** Healthy. No action required.
- Normal operation
- Keep MCPs connected only as needed
- Follow standard hygiene (no full file pastes, concise prompts)

### Yellow — 40–70% context
**Status:** Monitor and reduce.
- Run `/token-saver --status` to identify biggest consumers
- Disconnect MCPs not needed for the current task
- Stop pasting full files — use line ranges and snippets only
- Avoid asking Claude to re-explain or summarize what was just done
- Consider `/compact` if approaching 60%

### Red — 70%+ context
**Status:** Act immediately.
- Run `/token-saver --emergency`
- Disconnect ALL non-essential MCPs
- Run `/compact` immediately
- If task is complete, run `/clear` before starting the next one
- Break remaining work into a fresh session

---

## 18 Token Hygiene Techniques

### Category 1 — Context Reduction

1. **Compact wisely** — Run `/compact` at 60%, not 90%. Compacting earlier preserves more useful context in the summary.
2. **Clear between tasks** — Use `/clear` when switching to an unrelated task. Don't carry context from a deployment debug into a UI design session.
3. **Disconnect unused MCPs** — Each connected MCP costs ~17,600 tokens per message regardless of whether you use it. Disconnect all MCPs not needed for the current task via `/mcp`.
4. **Avoid re-reading large files** — If you already read a file this session, don't read it again. Reference it by name and line numbers instead.
5. **Archive resolved discussions** — If a bug is fixed and documented, it no longer needs to live in active context. Move it to a memory file and reference it by path.

### Category 2 — Input Optimization

6. **Paste only relevant code** — Never paste a full file when you need help with one function. Paste only the function, its signature, and the immediate surrounding context.
7. **Use line numbers** — Reference `file.ts:45-72` instead of pasting the content. Claude can read it if needed, but often the reference is enough.
8. **Compress your prompts** — "Fix the auth redirect bug on line 34 of `src/middleware.ts`" burns fewer tokens than a 3-paragraph explanation of the same problem.
9. **Group related prompts** — Send one message with 3 related questions instead of 3 separate messages. Each message has overhead beyond just your words.
10. **Avoid restating context** — Don't open messages with "As we discussed earlier..." summaries. Claude has the context. Jump straight to the ask.

### Category 3 — Output Control

11. **Ask for concise responses** — Add "be concise" or "skip explanation, just show code" when you don't need the reasoning. This halves many responses.
12. **Suppress re-explanation** — After Claude makes a change, don't ask "what did you do?" — it already told you. Read the diff or the output directly.
13. **Request targeted output** — "Show only the changed function" instead of "update the file and show me the result" prevents Claude from restating the entire file.
14. **Use structured formats** — Ask for bullet points or numbered lists instead of prose when you need scannable output. Shorter and easier to parse.

### Category 4 — MCP Hygiene

15. **Audit your MCP stack at session start** — Run `/mcp` at the beginning of each session and disconnect everything not needed. Don't leave last session's MCPs connected by default.
16. **One MCP at a time for heavy operations** — When running Playwright, Firecrawl, or Supabase operations, consider whether other MCPs need to be active simultaneously.
17. **Reconnect on demand** — It is faster to reconnect an MCP for 2 minutes than to pay its 17,600-token-per-message tax for an entire session.

### Category 5 — Loop Prevention

18. **Escape runaway loops** — If Claude is repeatedly trying the same fix, generating the same error, or spinning on a problem — press **Escape immediately**. In a loop, 80% of tokens produce zero value. Stop, reframe the problem, and restart with a fresh targeted prompt.

---

## Commands

### `/token-saver`
Full audit of the current session. Reports estimated context usage, identifies the top consumers (file reads, MCP overhead, conversation length), and applies the appropriate tier of hygiene actions.

**Output includes:**
- Estimated context percentage
- Traffic light status
- Top 3 token consumers in the session
- Recommended actions in priority order
- MCPs currently connected with per-message cost estimate

### `/token-saver --status`
Quick check. Reports current traffic light status and one-line summary of context health. No actions taken — just a read.

**Use when:** You want a fast read without triggering cleanup.

### `/token-saver --emergency`
Aggressive cleanup for Red zone situations. Applies all available reductions:
1. Lists all connected MCPs and prompts immediate disconnect of non-essential ones
2. Instructs compact to run at the next opportunity
3. Summarizes remaining active tasks into a minimal handoff note
4. Clears all non-essential context
5. Reports how many tokens were recovered

**Use when:** Context is above 70% and you have significant work remaining.

---

## Integration Notes

- Pair with `/context-optimizer` for structured archiving of resolved work
- Pair with `/pipeline-state` to checkpoint progress before a `/clear` so you can resume cleanly
- Run `/token-saver --status` as a habit every 15–20 messages in long sessions
- The best token optimization is prevention: start every session by disconnecting unused MCPs and committing to concise prompts
