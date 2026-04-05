#!/bin/bash
# Instalador automático — memoria-autoaprendizaje-claude
# Uso: curl -fsSL https://raw.githubusercontent.com/Marte1978/memoria-autoaprendizaje-claude/main/install.sh | bash

set -e

SKILLS_DIR="${HOME}/.claude/skills"
CLAUDE_DIR="${HOME}/.claude"
REPO="https://raw.githubusercontent.com/Marte1978/memoria-autoaprendizaje-claude/main"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 Instalando sistema de memoria Claude"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Crear directorios
mkdir -p "$SKILLS_DIR/briefing"
mkdir -p "$SKILLS_DIR/obsidian-context"
mkdir -p "$SKILLS_DIR/auto-learn"
mkdir -p "$CLAUDE_DIR/secrets"

# Descargar skills
echo "📥 Descargando skills..."
curl -fsSL "$REPO/skills/briefing/SKILL.md" -o "$SKILLS_DIR/briefing/SKILL.md"
echo "✅ /briefing"

curl -fsSL "$REPO/skills/obsidian-context/SKILL.md" -o "$SKILLS_DIR/obsidian-context/SKILL.md"
echo "✅ /obsidian-context"

curl -fsSL "$REPO/skills/auto-learn/SKILL.md" -o "$SKILLS_DIR/auto-learn/SKILL.md"
echo "✅ /auto-learn"

# Descargar sync script
curl -fsSL "$REPO/sync-from-github.sh" -o "$CLAUDE_DIR/sync-from-github.sh"
chmod +x "$CLAUDE_DIR/sync-from-github.sh"
echo "✅ sync-from-github.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Instalación completada"
echo ""
echo "Próximos pasos:"
echo "  1. Abre Claude Code"
echo "  2. Ejecuta /briefing en tu proyecto"
echo "  3. Para sync con Obsidian:"
echo "     echo 'tu_github_token' > ~/.claude/secrets/github.token"
echo "     Edita sync-from-github.sh con tu repo de Obsidian"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
