# Skill: /briefing

Sistema de contexto continuo entre sesiones de Claude Code. Mantiene un "documento vivo" que permite que cada sesión nueva arranque exactamente donde terminó la anterior, sin perder ni un detalle.

## Cuándo usar
- `/briefing --load` — **AL INICIO** de cada sesión: carga contexto completo + semáforo
- `/briefing --update` — **AL CERRAR** cada sesión: genera briefing actualizado
- `/briefing --status` — Durante la sesión: muestra semáforo de contexto
- `/briefing` — Primera vez en un proyecto: genera briefing inicial desde cero

## ARGUMENTS
- `/briefing` — Escanea el proyecto y genera briefing inicial
- `/briefing --load` — Carga `.briefing/latest.md` + estima interacciones restantes
- `/briefing --update` — Genera briefing actualizado + versiona + guarda como latest
- `/briefing --status` — Muestra semáforo: verde/amarillo/rojo según interacciones acumuladas

---

## EJECUCIÓN: `/briefing` (inicial)

### Paso 1 — Escanear el proyecto

```bash
# Estructura del proyecto
ls -la

# Últimos archivos modificados
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.md" | \
  xargs ls -lt 2>/dev/null | head -20

# Git log reciente (si aplica)
git log --oneline -10 2>/dev/null || echo "No es repo git"

# Pendientes en código
grep -r "TODO\|FIXME\|PENDIENTE\|HACK" --include="*.ts" --include="*.tsx" --include="*.js" -l 2>/dev/null | head -10
```

### Paso 2 — Crear `.briefing/` y briefing inicial

Crear la carpeta `.briefing/` si no existe y generar `latest.md` con esta estructura:

```markdown
# Briefing v1 — {NOMBRE_PROYECTO} — {FECHA}
> Generado: {TIMESTAMP} | Modelo: {MODELO}
> Sesión: INICIAL

## 🏗️ ESTADO ACTUAL
- **Fase**: [detectada del código/README]
- **Última sesión completó**: [primera sesión — proyecto nuevo]
- **Resultado**: En progreso

## ⚖️ DECISIONES TOMADAS
- **Stack**: [detectado de package.json / archivos presentes]
- **Arquitectura**: [detectada de estructura de carpetas]

## 📝 PENDIENTES (priorizados)
- [ ] 🔴 [extraídos de TODOs en código]
- [ ] 🟡 [extraídos de README pendientes]

## 📂 ARCHIVOS CLAVE
[árbol de los 10 archivos más relevantes]

## ⚠️ CONTEXTO CRÍTICO
- Errores conocidos: ninguno aún
- Patrones a respetar: [detectados del código]
- Restricciones: [detectadas de README/CLAUDE.md]

## 🚦 SEMÁFORO
- Complejidad estimada: MEDIA
- Interacciones recomendadas por sesión: 20
- Al llegar a 15 intercambios: ejecutar `/briefing --update` y abrir chat nuevo
```

Guardar en `.briefing/briefing-v1-{FECHA}.md` y copiar como `.briefing/latest.md`.

Agregar `.briefing/*.md` al `.gitignore` si existe (los briefings son locales, no se versiónan en git del proyecto).

---

## EJECUCIÓN: `/briefing --load`

### Paso 1 — Leer el briefing más reciente

```bash
cat .briefing/latest.md 2>/dev/null || echo "NO HAY BRIEFING — ejecuta /briefing primero"
```

### Paso 2 — Mostrar resumen ejecutivo

Presentar al usuario en formato compacto:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 BRIEFING CARGADO — {PROYECTO} v{N}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 ESTADO: {fase actual}
✅ ÚLTIMA SESIÓN: {qué se completó}

📝 PRÓXIMOS PASOS:
  1. {pendiente #1 crítico}
  2. {pendiente #2}
  3. {pendiente #3}

⚠️  CONTEXTO CRÍTICO:
  → {restricción o error conocido más importante}

🚦 SEMÁFORO: 🟢 VERDE — ~{N} intercambios disponibles
   (Pide /briefing --update cuando queden ~5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Listo. ¿Por dónde empezamos?
```

### Paso 3 — Estimar semáforo

Basado en la complejidad del briefing (número de pendientes, archivos clave, errores conocidos):
- **Briefing simple** (1-3 pendientes, proyecto pequeño): ~25 intercambios → 🟢
- **Briefing medio** (4-8 pendientes, varios archivos): ~20 intercambios → 🟢
- **Briefing complejo** (9+ pendientes, sistema grande): ~15 intercambios → 🟡 desde el inicio

**Regla de oro**: Cuando el usuario lleve ~15 intercambios densos (lecturas de archivo + ediciones + búsquedas), recordar: *"Llevamos ~{N} intercambios. Considera `/briefing --update` y abrir chat nuevo pronto."*

---

## EJECUCIÓN: `/briefing --update`

### Paso 1 — Determinar versión siguiente

```bash
# Contar versiones existentes
ls .briefing/briefing-v*.md 2>/dev/null | wc -l
```

Versión = (número encontrado + 1)

### Paso 2 — Generar briefing actualizado

Basado en TODO lo ocurrido en la sesión actual, generar el nuevo briefing con esta plantilla COMPLETA:

```markdown
# Briefing v{N} — {NOMBRE_PROYECTO} — {FECHA}
> Generado: {TIMESTAMP} | Modelo: claude-sonnet-4-6
> Sesión anterior: {descripción de 1 línea de qué se hizo}

## 🏗️ ESTADO ACTUAL
- **Fase**: {fase actual con precisión}
- **Esta sesión completó**:
  - {logro 1}
  - {logro 2}
- **Resultado**: {Funcionando / En progreso / Bloqueado — con detalle}

## ⚖️ DECISIONES TOMADAS
- **{Decisión técnica}**: {por qué se eligió} | descartado: {alternativa y razón}
- {repetir para cada decisión importante de esta sesión}

## 📝 PENDIENTES (priorizados)
- [ ] 🔴 CRÍTICO: {tarea bloqueante}
- [ ] 🟡 ALTO: {siguiente tarea importante}
- [ ] 🟢 NORMAL: {mejora o tarea menor}
{listar TODOS los pendientes conocidos}

## 📂 ARCHIVOS CLAVE MODIFICADOS ESTA SESIÓN
- `{ruta/archivo.ts}` — {qué cambió}
- `{ruta/archivo2.tsx}` — {qué cambió}

## ⚠️ CONTEXTO CRÍTICO
- **Errores conocidos**: {bugs activos o edge cases}
- **Patrones OBLIGATORIOS**: {reglas que NO se pueden romper}
- **Restricciones**: {limitaciones técnicas o de negocio}
- **Credenciales/Config**: {qué archivos de config son críticos}

## 🔗 COMANDOS ÚTILES PARA PRÓXIMA SESIÓN
```bash
{comando para continuar donde nos quedamos}
```

## 🚦 SEMÁFORO PRÓXIMA SESIÓN
- Complejidad: {BAJA/MEDIA/ALTA}
- Interacciones recomendadas: ~{N}
- Prioridad al iniciar: {lo más importante para la siguiente sesión}
```

### Paso 3 — Guardar y confirmar

```bash
# Guardar versión nueva
# Archivo: .briefing/briefing-v{N}-{FECHA}.md

# Actualizar latest
# Archivo: .briefing/latest.md (misma copia)
```

Output al usuario:
```
✅ BRIEFING v{N} GUARDADO
━━━━━━━━━━━━━━━━━━━━━━━━
📁 .briefing/briefing-v{N}-{FECHA}.md
📁 .briefing/latest.md (actualizado)

📝 Pendientes registrados: {N}
⚠️  Contexto crítico: {N items}

Para continuar en el próximo chat:
→ Abre un chat nuevo en Claude Code
→ Escribe: /briefing --load
→ Arrancas al 100% sin explicar nada
```

---

## EJECUCIÓN: `/briefing --status`

Mostrar el semáforo de la sesión actual:

```
🚦 SEMÁFORO DE SESIÓN
━━━━━━━━━━━━━━━━━━━━
Proyecto: {nombre}
Briefing: v{N} ({fecha})

Estado de contexto:
{representación visual según interacciones estimadas}

🟢 VERDE  (0-15):  Contexto fresco — máximo rendimiento
🟡 AMARILLO (15-22): Considera cerrar sesión pronto
🔴 ROJO  (22+):   Ejecuta /briefing --update AHORA y abre chat nuevo

Acción recomendada: {según el estado actual}
```

---

## Estructura de archivos

```
{proyecto}/
└── .briefing/
    ├── latest.md                        ← siempre el más reciente
    ├── briefing-v1-2026-04-05.md
    ├── briefing-v2-2026-04-05.md
    └── briefing-v3-2026-04-06.md
```

**Regla `.gitignore`**: Los briefings son contexto local de trabajo, no código. Agregar `.briefing/` al `.gitignore` del proyecto para no versionar con el código fuente.

---

## El ciclo perfecto

```
📥 /briefing --load          ← inicio de sesión (30 seg)
        ↓
⏱️  Semáforo: ~20 intercambios disponibles
        ↓
🏗️  Trabajar en los pendientes
        ↓
⚠️  ~15 intercambios: recordatorio automático
        ↓
📤 /briefing --update        ← fin de sesión (30 seg)
        ↓
🔄 Abrir chat nuevo → /briefing --load → 100% contexto
```

**Resultado**: Nunca más contexto degradado. Nunca más explicar el proyecto desde cero. Cada sesión es tan fresca como la primera.

---

## Integración con el sistema de memoria

Si el proyecto tiene memoria persistente (`~/.claude/projects/*/memory/`):
- `/briefing --update` puede sugerir guardar decisiones importantes como memories de tipo `project`
- Errores nuevos detectados → sugerir `/auto-learn` para documentarlos en KB-Master
- Al inicio del día → `/obsidian-context` primero, luego `/briefing --load`

**Orden recomendado al iniciar el día:**
1. `/obsidian-context` — sincroniza vault Obsidian completo
2. `/briefing --load` — carga contexto específico del proyecto
3. Trabajar
