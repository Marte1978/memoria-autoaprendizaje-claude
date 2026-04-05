#!/bin/bash
# Sync VPS Claude memories/skills ← → GitHub (Marte1978/claude-config)
# Corre cada 10 min via cron

TOKEN=$(cat ~/.claude/secrets/github.token 2>/dev/null)
REPO="Marte1978/claude-config"
CLONE_DIR="/tmp/claude-config-sync"
MEMORY_DIR="/root/.claude/projects/-root/memory"
SKILLS_DIR="/root/.claude/skills"
LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"

if [ -z "$TOKEN" ]; then
  echo "$LOG_PREFIX ERROR: No GitHub token en ~/.claude/secrets/github.token"
  exit 1
fi

# Clone o pull del repo
if [ -d "$CLONE_DIR/.git" ]; then
  cd "$CLONE_DIR"
  git pull --rebase "https://$TOKEN@github.com/$REPO.git" main -q 2>&1 | grep -v "^$"
else
  git clone "https://$TOKEN@github.com/$REPO.git" "$CLONE_DIR" -q
  cd "$CLONE_DIR"
fi

# PULL: sync carpetas de memoria GitHub → VPS (solo las subcarpetas numeradas + MEMORY.md)
for dir in 01-user 02-projects 03-knowledge-base 04-feedback 05-references 06-sessions; do
  if [ -d "$CLONE_DIR/$dir" ]; then
    mkdir -p "$MEMORY_DIR/$dir"
    rsync -a --delete "$CLONE_DIR/$dir/" "$MEMORY_DIR/$dir/"
  fi
done
cp "$CLONE_DIR/MEMORY.md" "$MEMORY_DIR/MEMORY.md"
echo "$LOG_PREFIX PULL: memories OK (GitHub → VPS)"

# PULL: skills GitHub → VPS (solo agregar/actualizar, no borrar skills VPS-only)
if [ -d "$CLONE_DIR/skills" ]; then
  mkdir -p "$SKILLS_DIR"
  # Copiar cada skill del repo sin borrar las que solo existen en VPS
  for skill_dir in "$CLONE_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    rsync -a "$CLONE_DIR/skills/$skill_name/" "$SKILLS_DIR/$skill_name/"
  done
  echo "$LOG_PREFIX PULL: skills OK (GitHub → VPS)"
fi

# PUSH: si el VPS creó memories nuevas, subirlas a GitHub
cd "$CLONE_DIR"

# Copiar memories del VPS al clone (solo las carpetas de memoria)
for dir in 01-user 02-projects 03-knowledge-base 04-feedback 05-references 06-sessions; do
  if [ -d "$MEMORY_DIR/$dir" ]; then
    mkdir -p "$CLONE_DIR/$dir"
    rsync -a "$MEMORY_DIR/$dir/" "$CLONE_DIR/$dir/"
  fi
done
cp "$MEMORY_DIR/MEMORY.md" "$CLONE_DIR/MEMORY.md"

# Commit y push si hay cambios
git config user.email "vps@webfactoryrd.com" 2>/dev/null
git config user.name "VPS Claude" 2>/dev/null
git add 01-user/ 02-projects/ 03-knowledge-base/ 04-feedback/ 05-references/ 06-sessions/ MEMORY.md

if ! git diff --cached --quiet; then
  git commit -m "sync: VPS memories $(date '+%Y-%m-%d %H:%M')" -q
  git push "https://$TOKEN@github.com/$REPO.git" main -q
  echo "$LOG_PREFIX PUSH: memories VPS → GitHub"
else
  echo "$LOG_PREFIX OK: sin cambios para push"
fi

echo "$LOG_PREFIX sync completo"
