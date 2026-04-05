---
name: auto-evolve
description: Sistema de auto-aprendizaje continuo — detecta, documenta y aplica conocimiento de cada sesion. Activar al final de sesiones significativas, despues de resolver errores, o cuando el usuario corrige un approach.
argument-hint: "[learn|review|report|scan]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

# Auto-Evolve — Sistema de Auto-Aprendizaje Continuo

> "El sistema se hace mas inteligente con cada sesion."

Tu mision: convertir cada interaccion en conocimiento persistente que mejore las sesiones futuras.

## Rutas (ajustar segun tu proyecto)

```
MEMORIA:     $HOME/.claude/memory/            (o donde tengas tu vault)
MEMORY.md:   $HOME/.claude/memory/MEMORY.md
KB-EVOLVE:   $HOME/.claude/memory/kb-evolution.md
```

---

## MODO 1: `/auto-evolve learn`

**Proposito:** Extraer aprendizajes de la sesion actual y documentarlos.

### Proceso

1. **ESCANEAR** el historial de la conversacion:
   - Errores encontrados y como se resolvieron
   - Correcciones del usuario ("no asi", "mejor hazlo de esta forma")
   - Herramientas/APIs/patrones nuevos descubiertos
   - Optimizaciones (formas mas rapidas)
   - Decisiones arquitectonicas tomadas

2. **CLASIFICAR** cada aprendizaje:

   | Tipo | Criterio |
   |------|----------|
   | `error` | Algo fallo y se arreglo — causa + fix + regla |
   | `patron` | Un approach funciono bien — documentar por que |
   | `preferencia` | Usuario indico como prefiere algo |
   | `optimizacion` | Se descubrio una forma mas eficiente |
   | `descubrimiento` | Herramienta, API, config o dato nuevo |

3. **VERIFICAR DUPLICADOS** — Leer kb-evolution.md antes de crear:
   - Si ya existe → actualizar contador de aplicaciones
   - Si es nuevo → crear entrada

4. **DOCUMENTAR** en `kb-evolution.md`:

   ```markdown
   ### [YYYY-MM-DD] [CODIGO] — Titulo corto
   - **Tipo**: error | patron | preferencia | optimizacion | descubrimiento
   - **Fuente**: conversacion | repo | deploy | debug | correccion-usuario
   - **Aprendizaje**: Que se aprendio (1-2 lineas)
   - **Regla**: Como aplicarlo en el futuro (imperativo, claro)
   - **Aplicado**: 0 veces
   - **Impacto**: alto | medio | bajo
   ```

   **Codigos por tipo:**
   - Errores: `ev-err-NNN`
   - Patrones: `ev-pat-NNN`
   - Preferencias: `ev-pref-NNN`
   - Optimizaciones: `ev-opt-NNN`
   - Descubrimientos: `ev-disc-NNN`

5. **ACTUALIZAR MEMORIAS** si el aprendizaje afecta una memoria existente.

6. **RESUMEN** al usuario:
   ```
   Auto-Evolve: N aprendizajes extraidos
   - X errores documentados
   - X patrones registrados
   - X preferencias actualizadas
   - X optimizaciones guardadas
   - X descubrimientos nuevos
   ```

---

## MODO 2: `/auto-evolve review`

**Proposito:** Auditar y mejorar las memorias existentes.

1. **LEER** todos los archivos en memoria
2. **VERIFICAR** cada memoria contra la realidad (archivos, URLs, repos)
3. **DETECTAR**: obsoletas, incompletas, duplicadas, fragmentadas
4. **PROPONER** cambios antes de ejecutar — esperar aprobacion del usuario
5. **EJECUTAR** solo con aprobacion

---

## MODO 3: `/auto-evolve report`

**Proposito:** Generar reporte de evolucion del sistema.

Leer kb-evolution.md y calcular:
- Total aprendizajes por tipo
- Top 5 mas aplicados
- Candidatos a eliminar (nunca aplicados >30 dias)
- Tendencias: area con mas errores, patron mas exitoso

```
## Reporte Auto-Evolve — [fecha]
- Total: N aprendizajes | Este mes: N | Aplicados: N veces
- Problemas sistemicos (3+ ocurrencias): [lista]
- Top patron: [ev-pat-NNN]
- Candidatos a eliminar: [lista]
```

---

## MODO 4: `/auto-evolve scan`

**Proposito:** Escanear repos buscando patrones para aprender.

1. Revisar repos recientes del usuario en GitHub
2. Analizar CLAUDE.md, README, package.json, workflows CI/CD
3. Extraer: librerias nuevas, patrones recurrentes, configuraciones, fix-commits
4. Documentar como descubrimientos en kb-evolution.md

---

## TRIGGERS AUTOMATICOS

Sugerir `/auto-evolve learn` cuando:
1. Error resuelto que no estaba documentado
2. Usuario corrige el approach ("no asi", "mejor hazlo", "para de")
3. Deploy exitoso con pasos no triviales
4. Primera vez usando una herramienta/API/servicio
5. Pipeline de cliente completado

**El trigger solo SUGIERE — no ejecuta sin confirmacion.**

---

## REGLAS DE ORO

1. **No duplicar** — Verificar que no exista antes de crear
2. **Fechas absolutas** — Nunca "ayer" o "la semana pasada"
3. **Una regla por aprendizaje** — Clara, imperativa, aplicable
4. **Impacto real** — Solo guardar lo que cambia comportamiento futuro
5. **Brevedad** — kb-evolution.md no debe pasar de 500 lineas
6. **Binario** — Cada aprendizaje se aplico o no. Sin escalas grises.
