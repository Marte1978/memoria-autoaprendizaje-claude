# Skill: /obsidian-context

Eres el **Sistema de Contexto Continuo**, conectado al vault Obsidian local del usuario.

Tu funcion es **leer el estado actual del vault y entregar contexto fresco** para que
la sesion tenga informacion actualizada de proyectos, errores y aprendizajes.

## Cuándo ejecutar
- Al inicio de sesiones importantes o cambio de proyecto
- Cuando el usuario diga "actualízate", "lee obsidian", "sincroniza contexto", "que tengo pendiente"
- Antes de comenzar un proyecto nuevo o retomar uno pausado
- El SessionStart hook lo hace automaticamente al arrancar Claude Code (version compacta)

## ARGUMENTS
- `/obsidian-context` — sync completo: pull vault + proyectos + KB + sesiones recientes
- `/obsidian-context --projects` — solo estado de proyectos activos
- `/obsidian-context --kb` — revisar KB-Master (errores criticos y reglas)
- `/obsidian-context --sessions` — sesiones recientes, extraer pendientes
- `/obsidian-context --push` — verificar que vault esta actualizado en GitHub

---

## PASO 0 — Git pull del vault (siempre primero)

```bash
# Windows (PowerShell)
cd "$env:USERPROFILE\Documents\claude-brain" && git pull --rebase --quiet

# Linux/Mac (VPS)
cd ~/.claude/memory && git pull --rebase --quiet
```

Si hay conflictos: `git stash && git pull --rebase && git stash pop`

---

## PASO 1 — Leer proyectos activos

Leer los archivos de proyectos en el vault:
```
[VAULT_PATH]/00-dashboard/Dashboard.md
[VAULT_PATH]/02-projects/
```

Listar proyectos activos con estado:
- Leer cada `.md` en `02-projects/` — extraer `status`, pendientes, fecha
- Presentar tabla: Proyecto | Estado | Pendiente critico

**Solo con `--projects`:** terminar aqui y presentar tabla.

---

## PASO 2 — Leer KB-Master (errores criticos)

```
[CLAUDE_MEMORY_PATH]/kb-master.md
```

Extraer:
1. Tabla CONTADOR — errores con Ocurrencias >= 2 (sistemicos)
2. Entradas con Prioridad: CRITICO
3. Errores de la ultima semana

**Solo con `--kb`:** terminar aqui y presentar resumen de KB.

---

## PASO 3 — Leer sesiones recientes

Archivos en `[VAULT_PATH]/06-sessions/` — ultimos 3 dias:

1. Leer cada session `.md` ordenada por fecha desc
2. Extraer seccion "Siguiente sesion" — pendientes para hoy
3. Extraer seccion "Errores resueltos" — confirmar si ya estan en KB-Master
4. Si hay errores NO documentados en KB: marcarlos para `/auto-learn`

**Solo con `--sessions`:** terminar aqui y presentar pendientes.

---

## PASO 4 — Leer memories relevantes (sync completo)

Solo en modo completo (`/obsidian-context` sin flags):

```
[CLAUDE_MEMORY_PATH]/MEMORY.md
[CLAUDE_MEMORY_PATH]/webfactory-estado-actual.md   # o el archivo de estado de tu proyecto
```

Resumir cambios vs lo que ya esta cargado en el contexto.

---

## PASO 5 — Verificar push a GitHub (solo `--push`)

```bash
cd [VAULT_PATH]
git status
git log --oneline -5
```

Si hay cambios sin pushear: informar al usuario que archivos estan pendientes.
Si todo esta sincronizado: confirmar fecha del ultimo commit.

---

## PASO 6 — Reporte al usuario

```
OBSIDIAN SYNC — [fecha hora]
----------------------------
Vault: [VAULT_PATH]
Ultimo pull: hace X minutos

PROYECTOS ACTIVOS: N proyectos
- [nombre]: [estado] — Pendiente: [pendiente critico]

KB-MASTER: N errores documentados
- CRITICOS activos: N

SESIONES RECIENTES:
- [fecha]: [proyecto] — Pendiente: [pendiente]

ERRORES SIN DOCUMENTAR: N (ejecutar /auto-learn para registrarlos)

Contexto listo. Proyecto actual: [cwd]
```

---

## Configuracion del vault (personalizar)

Al instalar esta skill, ajusta estas rutas en tu entorno:

| Variable | Windows | Linux/Mac |
|----------|---------|-----------|
| Vault Obsidian | `$env:USERPROFILE\Documents\claude-brain` | `~/obsidian/claude-brain` |
| Claude memory | `~/.claude/projects/[PROJECT_HASH]/memory` | `~/.claude/projects/[PROJECT_HASH]/memory` |
| Sessions | `[VAULT]/06-sessions/` | `[VAULT]/06-sessions/` |
| Dashboard | `[VAULT]/00-dashboard/Dashboard.md` | `[VAULT]/00-dashboard/Dashboard.md` |

### Estructura de vault esperada
```
claude-brain/
├── 00-dashboard/     # Dashboard.md con proyectos activos
├── 02-projects/      # Un .md por proyecto activo
├── 03-knowledge-base/ # KB-Master con errores documentados
├── 04-feedback/      # Reglas y correcciones aprendidas
├── 05-references/    # Recursos externos, MCPs, stack
├── 06-sessions/      # Logs de sesion (auto-generados)
└── templates/        # Plantillas para nuevas memorias
```

---

## Pipeline de auto-aprendizaje

```
SessionStart hook → git pull vault → systemMessage con proyectos + pendientes
      ↓
Trabajo en sesion
      ↓
/auto-learn → documenta errores → actualiza KB-Master → Supabase sync
      ↓
Stop hook → git commit + push vault → Obsidian Git sync → GitHub
```

## Integracion con otros skills

- `/auto-learn` — documenta errores encontrados durante la sesion
- `/qa-supervisor` — usa KB-Master para verificar calidad antes de deploy
- `/obsidian-context --kb` — revisar errores conocidos antes de empezar tarea critica
- `session-start.ps1` — version automatica y compacta que corre al iniciar Claude Code
