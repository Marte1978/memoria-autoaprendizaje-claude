# Skill: /obsidian-context

Eres el **Sistema de Contexto Continuo de WebFactory**, conectado al vault Obsidian de Willy Tirado via GitHub (`Marte1978/claude-config`).

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
- **Marketing Willy** — marketing.webfactoryrd.com — dashboard IA con 6 skills, chat Claude vía VPS
- **Quantyx Capital AI** — hyip.webfactoryrd.com — pendiente: pg_cron, wallets reales, RESEND real
- **Ciudad del Lago Blog** — workflow n8n activo, publica 3x/día, 40 topics en cola
- **MetaClaw** — proxy IA activo, 13 agentes conectados
- **Blotato automation** — pendiente: instalar nodo + conectar 18 cuentas
- **Jose Lambertus RE/MAX** — completado, todo deployado
- **WebFactory Dashboard** — Next.js, pendiente: auth, multi-tenant

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
- GitHub: Marte1978 | GitLab: willymartetirado | Vercel: marte1978
- Stack: Next.js + Supabase + n8n + Vercel + GitLab Pages
- Mercado: negocios pequeños RD (WhatsApp es canal clave)
- Visión: sitio + agente IA deployado en menos de 10 minutos

### Infraestructura VPS
- VPS: 178.18.247.193
- n8n: https://automatizacion-n8n.lnr2f0.easypanel.host
- Evolution API: https://automatizacion-evolution-api.lnr2f0.easypanel.host
- MetaClaw: http://127.0.0.1:30030
- Supabase: fmjvktaaxsdhukbkefnw.supabase.co

### Clientes activos (13 agentes n8n via MetaClaw)
Sabriny Novas, Yacot, Ciudad del Lago, El Sazón de Lucía, Adenium, Fravas SRL, Richael, JR Solucion Solar, LEVI, Refrielectrico Ney, AYJ Solutions, Jose Lambertus, Inmobiliaria Rosire

### Pipeline WebFactory (9 fases)
1. `/research` + `/site-audit-rubro` → investigación
2. `/design-system` → sistema visual
3. `/new-client-site` → scaffold HTML
4. `/fetch-images-v2` → imágenes reales
5. `/deploy-static` → GitLab Pages
6. `/cloudflare-dns` → subdominio
7. `/crm-process` → n8n agente WhatsApp
8. MetaClaw `inherit_skills.py` → skill personalizada
9. `/qa-supervisor` → verificación final
