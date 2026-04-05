# Skill: /obsidian-context

Eres el **Sistema de Contexto Continuo**, conectado al vault Obsidian via GitHub (`YOUR_GITHUB_USER/YOUR_CONFIG_REPO`).

Tu función es **leer el estado actual del vault, procesar los aprendizajes nuevos y actualizar la memoria del VPS** para que cada sesión de Claude Code tenga el contexto más completo posible.

## Cuándo ejecutar
- Al inicio de cualquier sesión importante
- Antes de comenzar un proyecto nuevo
- Cuando Willy diga "actualízate", "lee obsidian", "sincroniza contexto"
- Automáticamente cada día via cron (SessionStart hook)

## ARGUMENTS
- `/obsidian-context` — sync completo: leer vault + actualizar memories + aplicar contexto
- `/obsidian-context --sessions` — procesar solo sesiones recientes, extraer aprendizajes
- `/obsidian-context --projects` — actualizar estado de proyectos activos
- `/obsidian-context --kb` — revisar KB-Master por errores nuevos a interiorizar
- `/obsidian-context --push` — subir memories nuevas del VPS al vault Obsidian

---

## PASO 1 — Sincronizar con GitHub

```bash
/root/.claude/sync-from-github.sh
```

Esto hace PULL de todas las memories y skills del vault Obsidian al VPS.

---

## PASO 2 — Leer estado de proyectos activos

Proyectos activos en WebFactory:
- **YOUR_PROJECT_1 — your-domain.com — descripción del proyecto
- **YOUR_PROJECT_2 — your-domain.com — pendientes del proyecto
- **YOUR_PROJECT_3 — workflow activo
- **YOUR_TOOL_1 — descripción
- **YOUR_TOOL_2 — pendientes
- **YOUR_PROJECT_4 — completado
- **YOUR_DASHBOARD — pendientes

---

## PASO 3 — Leer memories relevantes

```bash
cat ~/.claude/memory/MEMORY.md
cat ~/.claude/memory/kb-master.md
cat ~/.claude/memory/webfactory-estado-actual.md
cat ~/.claude/memory/reference-credenciales.md
```

---

## PASO 4 — Detectar y documentar aprendizajes nuevos

Si en las sesiones recientes hay errores NO documentados en KB-Master:

### Formato para agregar al KB-Master
```bash
cat >> ~/.claude/projects/-root/memory/03-knowledge-base/kb-master.md << 'EOF'

### [CÓDIGO-NUEVO] — [Nombre del error]
**Skill afectada**: [skill]
**Síntoma**: [qué pasó]
**Causa raíz**: [por qué]
**Fix**: [cómo se resolvió]
**Prevención**: [regla para no repetirlo]
**Ocurrencias**: 1
**Prioridad**: [CRÍTICO/ALTO/MEDIO/BAJO]
EOF
```

### Push al vault Obsidian
```bash
/root/.claude/sync-from-github.sh --push
```

---

## PASO 5 — Confirmar estado al usuario

Reportar:
```
✅ Contexto Obsidian cargado
📚 [N] memories procesadas
🔧 [N] reglas de feedback activas
⚠️ [N] errores KB-Master interiorizados
📁 [N] proyectos activos actualizados
🆕 [N] aprendizajes nuevos detectados (si aplica)

Proyectos con pendientes críticos:
- [nombre]: [pendiente]

Listo para trabajar con contexto completo.
```

---

## Contexto WebFactory RD (siempre activo)

### Quién es Willy
- Fundador WebFactoryRD — agencia digital República Dominicana
- GitHub: YOUR_GITHUB_USER
- Stack: Next.js + Supabase + n8n + Vercel + GitLab Pages
- Mercado: negocios pequeños RD (WhatsApp es canal clave)
- Visión: sitio + agente IA deployado en menos de 10 minutos

### Infraestructura VPS
- VPS: YOUR_VPS_IP
- n8n: YOUR_N8N_URL
- Evolution API: YOUR_EVOLUTION_API_URL
- YOUR_TOOL: YOUR_INTERNAL_URL
- Supabase: YOUR_SUPABASE_REF.supabase.co

### Clientes activos (lista de clientes via tu herramienta de agentes)
Cliente 1, Cliente 2, Cliente 3, ... (personalizar con tus clientes)

### Pipeline WebFactory (9 fases)
1. `/research` + `/site-audit-rubro` → investigación
2. `/design-system` → sistema visual
3. `/new-client-site` → scaffold HTML
4. `/fetch-images-v2` → imágenes reales
5. `/deploy-static` → GitLab Pages
6. `/cloudflare-dns` → subdominio
7. `/crm-process` → n8n agente WhatsApp
8. YOUR_TOOL → skill personalizada
9. `/qa-supervisor` → verificación final
