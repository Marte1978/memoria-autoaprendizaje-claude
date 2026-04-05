#!/bin/bash
# Sync Claude memories/skills <-> GitHub (vault Obsidian)
# Corre cada 10 min via cron
#
# Setup:
#   1. echo "tu_github_token" > ~/.claude/secrets/github.token && chmod 600 ~/.claude/secrets/github.token
#   2. Editar REPO y MEMORY_DIR abajo segun tu usuario
#   3. crontab -e → agregar: */10 * * * * /ruta/a/sync-from-github.sh

# ─── CONFIG ────────────────────────────────────────────────────────────────────
TOKEN=$(cat ~/.claude/secrets/github.token 2>/dev/null)
REPO="TU_USUARIO/claude-config"                    # <-- cambiar
MEMORY_DIR="$HOME/.claude/memory"                  # <-- ajustar si usas otra ruta
SKILLS_DIR="$HOME/.claude/skills"
CLONE_DIR="/tmp/claude-config-sync"
LOG="$HOME/.claude/sync-github.log"
LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"
# ───────────────────────────────────────────────────────────────────────────────

if [ -z "$TOKEN" ]; then
  echo "$LOG_PREFIX ERROR: No GitHub token en ~/.claude/secrets/github.token" | tee -a "$LOG"
  exit 1
fi

# Clone o pull del repo
if [ -d "$CLONE_DIR/.git" ]; then
  cd "$CLONE_DIR"
  git pull --rebase "https://$TOKEN@github.com/$REPO.git" main -q 2>/dev/null
else
  git clone "https://$TOKEN@github.com/$REPO.git" "$CLONE_DIR" -q
  cd "$CLONE_DIR"
fi

# PULL: memories GitHub → local (subcarpetas numeradas + MEMORY.md)
mkdir -p "$MEMORY_DIR"
for dir in 01-user 02-projects 03-knowledge-base 04-feedback 05-references 06-sessions; do
  if [ -d "$CLONE_DIR/$dir" ]; then
    mkdir -p "$MEMORY_DIR/$dir"
    rsync -a --delete "$CLONE_DIR/$dir/" "$MEMORY_DIR/$dir/"
  fi
done
[ -f "$CLONE_DIR/MEMORY.md" ] && cp "$CLONE_DIR/MEMORY.md" "$MEMORY_DIR/MEMORY.md"
echo "$LOG_PREFIX PULL: memories OK (GitHub → local)" >> "$LOG"

# PULL: skills GitHub → local (agregar/actualizar, no borrar skills locales)
if [ -d "$CLONE_DIR/skills" ]; then
  mkdir -p "$SKILLS_DIR"
  for skill_dir in "$CLONE_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    rsync -a "$CLONE_DIR/skills/$skill_name/" "$SKILLS_DIR/$skill_name/"
  done
  echo "$LOG_PREFIX PULL: skills OK (GitHub → local)" >> "$LOG"
fi

# PUSH: memories nuevas del local a GitHub
cd "$CLONE_DIR"
for dir in 01-user 02-projects 03-knowledge-base 04-feedback 05-references 06-sessions; do
  if [ -d "$MEMORY_DIR/$dir" ]; then
    mkdir -p "$CLONE_DIR/$dir"
    rsync -a "$MEMORY_DIR/$dir/" "$CLONE_DIR/$dir/"
  fi
done
[ -f "$MEMORY_DIR/MEMORY.md" ] && cp "$MEMORY_DIR/MEMORY.md" "$CLONE_DIR/MEMORY.md"

git config user.email "claude@local" 2>/dev/null
git config user.name "Claude Code VPS" 2>/dev/null
git add 01-user/ 02-projects/ 03-knowledge-base/ 04-feedback/ 05-references/ 06-sessions/ MEMORY.md 2>/dev/null

if ! git diff --cached --quiet; then
  git commit -m "sync: memories $(date '+%Y-%m-%d %H:%M')" -q
  git push "https://$TOKEN@github.com/$REPO.git" main -q 2>/dev/null
  echo "$LOG_PREFIX PUSH: memories local → GitHub" >> "$LOG"
else
  echo "$LOG_PREFIX OK: sin cambios" >> "$LOG"
fi
