# 🧠 Memoria y Autoaprendizaje Continuo para Claude Code

Sistema completo de **memoria persistente**, **autoaprendizaje** y **contexto continuo entre sesiones** para Claude Code en terminal.

> Desarrollado por [Willy Tirado](https://github.com/Marte1978) — WebFactory RD

---

## ¿Qué resuelve?

¿Tu Claude "se vuelve tonto" después de 1 hora? ¿Tienes que explicar tu proyecto desde cero en cada sesión? Este sistema elimina esos problemas de raíz.

**En la web (claude.ai)**: el briefing es manual — copy-paste de contexto.  
**En la terminal (Claude Code)**: Claude lee y escribe archivos directamente. El sistema es completamente automático.

---

## 📦 Skills incluidas

### 🗒️ `/briefing` — Sistema de Briefing Automático
El skill más importante del sistema. Mantiene un "documento vivo" que permite que cada sesión nueva arranque exactamente donde terminó la anterior.

**Flujo perfecto:**
```
📥 /briefing --load      → inicio de sesión (30 seg, contexto 100%)
🏗️  Trabajar...
⚠️  ~15 intercambios → recordatorio automático
📤 /briefing --update    → fin de sesión (30 seg, versionado)
🔄 Chat nuevo → /briefing --load → sin perder nada
```

**Comandos:**
| Comando | Cuándo |
|---------|--------|
| `/briefing` | Primera vez en un proyecto |
| `/briefing --load` | AL INICIO de cada sesión |
| `/briefing --update` | AL CERRAR cada sesión |
| `/briefing --status` | Semáforo de contexto en tiempo real |

**Semáforo de sesión:**
- 🟢 `0-15 intercambios` — Contexto fresco, máximo rendimiento
- 🟡 `15-22 intercambios` — Considera cerrar sesión pronto
- 🔴 `22+ intercambios` — Ejecuta `/briefing --update` AHORA

---

### 🌐 `/obsidian-context` — Sincronización con Vault Obsidian
Conecta Claude Code con tu vault Obsidian via GitHub. Cada sesión puede cargar el contexto completo de todos tus proyectos, errores documentados, reglas de trabajo y más.

**Requisito**: Vault Obsidian sincronizado con un repo GitHub.

**Comandos:**
| Comando | Función |
|---------|---------|
| `/obsidian-context` | Sync completo: pull GitHub + leer vault + aplicar contexto |
| `/obsidian-context --sessions` | Procesar sesiones recientes, extraer aprendizajes |
| `/obsidian-context --projects` | Actualizar estado de proyectos activos |
| `/obsidian-context --kb` | Revisar knowledge base por errores nuevos |
| `/obsidian-context --push` | Subir memories nuevas del VPS al vault |

---

### 📚 `/auto-learn` — Aprendizaje Automático de Errores
Analiza errores detectados por QA, los clasifica y actualiza automáticamente las reglas del sistema para que ese error nunca se repita.

**Comandos:**
| Comando | Función |
|---------|---------|
| `/auto-learn [proyecto]` | Aprende del proyecto recién completado |
| `/auto-learn --review` | Análisis semanal de patrones acumulados |
| `/auto-learn --deploy-fail [proyecto]` | Error en deploy específico |

---

## 🔄 Script de Sync Bidireccional

`sync-from-github.sh` — Sincroniza memories y skills entre VPS y GitHub/Obsidian cada 10 minutos via cron.

**Setup:**
```bash
# 1. Copiar el script
cp sync-from-github.sh ~/.claude/sync-from-github.sh
chmod +x ~/.claude/sync-from-github.sh

# 2. Configurar tu GitHub token
echo "tu_github_token" > ~/.claude/secrets/github.token

# 3. Agregar al cron
crontab -e
# Agregar: */10 * * * * /root/.claude/sync-from-github.sh >> /root/.claude/sync-github.log 2>&1
```

---

## 🚀 Instalación rápida

### Opción A: Manual
```bash
# Clonar este repo
git clone https://github.com/Marte1978/memoria-autoaprendizaje-claude.git

# Copiar skills a Claude Code
cp -r skills/briefing ~/.claude/skills/
cp -r skills/obsidian-context ~/.claude/skills/
cp -r skills/auto-learn ~/.claude/skills/

# Copiar script de sync
cp sync-from-github.sh ~/.claude/sync-from-github.sh
chmod +x ~/.claude/sync-from-github.sh
```

### Opción B: Un solo comando
```bash
curl -fsSL https://raw.githubusercontent.com/Marte1978/memoria-autoaprendizaje-claude/main/install.sh | bash
```

---

## 📁 Estructura del repositorio

```
memoria-autoaprendizaje-claude/
├── README.md
├── install.sh                          ← instalador automático
├── sync-from-github.sh                 ← sync bidireccional VPS ↔ GitHub
└── skills/
    ├── briefing/
    │   └── SKILL.md                    ← /briefing
    ├── obsidian-context/
    │   └── SKILL.md                    ← /obsidian-context
    └── auto-learn/
        └── SKILL.md                    ← /auto-learn
```

---

## 💡 Flujo recomendado del día

```
Mañana (inicio):
  1. /obsidian-context     → sincroniza vault Obsidian completo
  2. /briefing --load      → carga contexto del proyecto

Durante el trabajo:
  3. Trabajar en bloques de 45-90 min
  4. /briefing --status    → si dudas del estado del contexto

Al cerrar:
  5. /briefing --update    → versiona el briefing
  6. /auto-learn [cliente] → si hubo errores o proyecto completado
```

---

## 🏗️ Stack compatible

- **Claude Code** (CLI) en Linux/Mac/Windows WSL
- **Obsidian** con sync a GitHub (opcional para `/obsidian-context`)
- **Cualquier proyecto**: Next.js, Python, n8n, sitios estáticos, etc.

---

## 📄 Licencia

MIT — Libre para usar, modificar y distribuir.

---

*Creado con Claude Code + WebFactory RD*
