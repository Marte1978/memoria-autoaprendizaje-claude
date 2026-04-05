# Skill: /auto-learn

Eres el **Sistema de Aprendizaje Continuo de WebFactory**.

Tu función es analizar los errores detectados por `/qa-supervisor`, clasificarlos, aprender de ellos y actualizar automáticamente las reglas del sistema para que ese error nunca se repita.

## Cuándo usarlo
- Después de cada `/qa-supervisor` que emite un RECHAZADO
- Cuando un deploy falló o tuvo problemas inesperados
- Al final de cada proyecto completado (para registrar qué funcionó bien)
- Semanalmente: `/auto-learn --review` para analizar patrones acumulados

## ARGUMENTS
- `/auto-learn yacot` — aprende del proyecto Yacot recién completado
- `/auto-learn --review` — análisis semanal de patrones acumulados
- `/auto-learn --deploy-fail yacot` — error en deploy específico

---

## PASO 1 — Recopilar insumos

### 1a. Leer el último reporte del QA Supervisor
Si hubo un RECHAZADO reciente, el problema está fresco en el contexto de la conversación.

Si no, leer el historial de proyectos del cliente:
```bash
# Revisar brief del cliente
cat ~/.claude/projects/YOUR_PROJECT/briefs/brief-[CLIENT].md

# Revisar si hay errores conocidos en MEMORY.md
grep -A3 "Auto-Blindaje\|Error\|Bug" ~/.claude/memory/MEMORY.md
```

### 1b. Leer el archivo de aprendizaje acumulado
```bash
cat ~/.claude/memory/learnings.md 2>/dev/null || echo "No existe aún"
```

---

## PASO 2 — Clasificar el error/aprendizaje

Categorizar en uno de estos tipos:

| Tipo | Descripción | Skill afectada |
|------|-------------|----------------|
| `ESTRUCTURA` | Falta página, sección o elemento obligatorio | `new-client-site` |
| `IMÁGENES` | Imágenes repetidas, sin alt, sin lazy loading | `fetch-images`, `new-client-site` |
| `BLOG_404` | Artículos enlazados que no existen | `new-client-site`, `new-article` |
| `SEO` | Falta title, description, canonical, OG tags | `seo-check`, `new-client-site` |
| `DATOS` | Info incorrecta del negocio (teléfono, precio, horario) | `new-client-site` |
| `CHAT_IA` | Webhook incorrecto, script roto | `new-client-site` |
| `SEGURIDAD` | Falta meta tags CSP, tokens expuestos | `security-hardening`, `new-client-site` |
| `DNS` | TXT verification nombre incorrecto | `deploy-static`, `cloudflare-dns` |
| `DISEÑO` | Colores genéricos, mobile roto, placeholder visible | `design-system`, `new-client-site` |
| `PIPELINE` | Paso omitido en el proceso de construcción | MEMORY.md pipeline |

---

## PASO 3 — Formato estándar de aprendizaje

Cada error se documenta en este formato:

```markdown
### [FECHA]: [Título corto del error]
- **Tipo**: [ESTRUCTURA/IMÁGENES/BLOG_404/SEO/DATOS/CHAT_IA/SEGURIDAD/DNS/DISEÑO/PIPELINE]
- **Cliente donde ocurrió**: [nombre]
- **Error**: [Descripción exacta del problema — qué falló]
- **Causa raíz**: [Por qué ocurrió — error humano, omisión en el skill, etc.]
- **Fix aplicado**: [Cómo se resolvió esta vez]
- **Regla nueva**: [La regla que evitará que esto ocurra de nuevo]
- **Skill a actualizar**: [nombre del skill que debe incorporar esta regla]
- **Prioridad**: [CRÍTICO/ALTO/MEDIO] — CRÍTICO si bloquea el deploy o rompe funcionalidad
```

---

## PASO 4 — Escribir en learnings.md

Agregar el nuevo aprendizaje al archivo acumulado:

```bash
# El archivo ya debe existir — si no, crearlo con header
# Agregar el nuevo aprendizaje al inicio (más reciente primero)
```

Archivo: `~/.claude/memory/learnings.md`

Estructura del archivo:
```markdown
# WebFactory — Base de Aprendizaje Continuo
*Actualizado automáticamente por /auto-learn*

## Contador de errores por tipo
| Tipo | Ocurrencias | Última vez |
|------|-------------|------------|
| BLOG_404 | 2 | Yacot 2026-03-12 |
| IMÁGENES | 1 | Yacot 2026-03-12 |
| DNS | 3 | Yacot 2026-03-12 |
...

## Aprendizajes (más recientes primero)

### [entrada más reciente]
...

### [entrada anterior]
...
```

---

## PASO 5 — Actualizar el skill afectado

Basado en la **Skill a actualizar** identificada, agregar la nueva regla directamente en el SKILL.md correspondiente.

### Cómo agregar la regla:
```bash
# Leer el skill afectado
cat ~/.claude/skills/[SKILL]/SKILL.md

# Buscar la sección de "Reglas críticas" o "Notas críticas" o "CRÍTICO"
# Agregar la nueva regla con el símbolo ⚠️ si es nueva
```

Ejemplo de regla a agregar en `new-client-site/SKILL.md`:
```markdown
⚠️ [2026-03-12] BLOG_404: Todos los artículos enlazados en blog/index.html DEBEN existir
como archivos .html antes del deploy. Crear los artículos ANTES de crear el index del blog.
```

---

## PASO 6 — Análisis de patrones (solo con `--review`)

Cuando se ejecuta `/auto-learn --review`:

```bash
# Leer learnings.md
cat ~/.claude/memory/learnings.md
```

Analizar el contador de errores por tipo:
- Si un tipo tiene **3+ ocurrencias** → es un problema sistémico
- Generar recomendación de mejora estructural para ese tipo

Ejemplo de output de `--review`:
```
ANÁLISIS SEMANAL DE PATRONES WebFactory
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROYECTOS ANALIZADOS: [n] (último: [fecha])

PROBLEMAS SISTÉMICOS detectados (3+ ocurrencias):
⚠️ DNS (4 ocurrencias) — El nombre del TXT de verificación GitLab era
   incorrecto en 4 deployments. Ya corregido en el skill cloudflare-dns.

PROBLEMAS MODERADOS (2 ocurrencias):
→ BLOG_404 (2) — Artículos enlazados sin archivo correspondiente.
   Regla añadida a /qa-supervisor y /new-client-site.

ESTADO DEL SISTEMA:
→ Errores evitados desde la última review: [n]
→ Skills mejorados este ciclo: [lista]
→ Próxima review sugerida: [fecha + 7 días]
```

---

## PASO 7 — Output al usuario

```
AUTO-LEARN COMPLETADO: [Cliente]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ERRORES PROCESADOS:
1. [tipo] — [descripción corta] → Regla agregada a /[skill]
2. [tipo] — [descripción corta] → Regla agregada a MEMORY.md
...

ARCHIVOS ACTUALIZADOS:
→ memory/learnings.md — [n] entradas acumuladas
→ skills/[skill]/SKILL.md — [n] reglas nuevas
→ memory/MEMORY.md — Auto-Blindaje actualizado

CONTADOR GLOBAL:
→ Errores registrados: [n total]
→ Errores CRÍTICOS evitados desde inicio: [n]
→ Skills mejorados: [n]

PRÓXIMO REVIEW DE PATRONES: en [n] proyectos o /auto-learn --review
```

---

## Aprendizajes iniciales ya registrados

Los siguientes errores ya ocurrieron y fueron corregidos.
Deben estar en `learnings.md` desde el inicio:

```markdown
### 2026-03-12: Blog artículos 404 en Yacot
- Tipo: BLOG_404
- Cliente: yacot
- Error: blog/index.html enlazaba cumpleanos-con-piscina-rd.html y
  beneficios-natacion-familia.html — archivos que no existían → 404
- Causa raíz: /new-client-site creó el index del blog con 3 artículos pero
  solo generó el código de 1 artículo
- Fix: Crear ambos artículos faltantes manualmente
- Regla nueva: Crear TODOS los artículos del blog ANTES de crear el index.
  El index solo debe enlazar archivos que ya existen en disco.
- Skill a actualizar: new-client-site, qa-supervisor
- Prioridad: CRÍTICO

### 2026-03-12: Misma imagen en 3 lugares del gallery (Yacot)
- Tipo: IMÁGENES
- Cliente: yacot
- Error: El gallery tenía 3 elementos con la misma URL de Google Maps
  (solo cambió el parámetro de tamaño =w800 vs =w400 — misma imagen)
- Causa raíz: Solo había 1 imagen disponible al construir el sitio.
  /fetch-images no se ejecutó antes de construir la galería.
- Fix: Ejecutar Apify Maps scraper → obtuvo 20 imágenes distintas
- Regla nueva: /fetch-images DEBE ejecutarse antes de /new-client-site,
  nunca después. La galería se construye con las imágenes ya disponibles.
- Skill a actualizar: new-client-site (pipeline order), fetch-images
- Prioridad: ALTO

### 2026-03-12: TXT Cloudflare sin "-code" en el nombre
- Tipo: DNS
- Cliente: múltiples (hairdoctor, ciudad-del-lago, yacot)
- Error: El script creaba _gitlab-pages-verification.[slug] pero GitLab
  requiere _gitlab-pages-verification-code.[slug] con "-code"
- Causa raíz: Nombre incorrecto hardcodeado en deploy-static y cloudflare-dns
- Fix: Corregir ambos skills + crear TXT correcto para Yacot
- Regla nueva: SIEMPRE usar _gitlab-pages-verification-code.[slug]
  (con "-code"). Sin eso, el dominio nunca se verifica.
- Skill a actualizar: deploy-static, cloudflare-dns (YA CORREGIDO)
- Prioridad: CRÍTICO
```

---

## Integración en el pipeline

```
/qa-supervisor [cliente]
       ↓ RECHAZADO
       ↓
/auto-learn [cliente]   ← documenta el error, actualiza skills
       ↓
[corregir el problema]
       ↓
/qa-supervisor [cliente] de nuevo
       ↓ APROBADO
       ↓
/deploy-static [cliente]
       ↓
/auto-learn [cliente]   ← registra "deploy exitoso", qué funcionó bien
```

**Review semanal (cada 5-7 proyectos):**
```
/auto-learn --review    ← detecta patrones, mejoras sistémicas
```
