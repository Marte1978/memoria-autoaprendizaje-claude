# session-start.ps1
# Hook SessionStart de Claude Code
#
# Al iniciar Claude Code:
#   1. Hace git pull del vault Obsidian (contexto fresco)
#   2. Crea log de sesion en 06-sessions/
#   3. Inyecta contexto clave del vault como systemMessage
#
# CONFIGURACION: Ajusta VAULT_PATH a la ruta de tu vault Obsidian

$VAULT        = "$env:USERPROFILE\Documents\claude-brain"   # <-- Cambia esto a tu vault
$SESSIONS_DIR = "$VAULT\06-sessions"
$timestamp    = Get-Date -Format "yyyy-MM-dd-HH"
$date         = Get-Date -Format "yyyy-MM-dd"
$hour         = Get-Date -Format "HH:mm"
$outFile      = "$SESSIONS_DIR\$timestamp.md"

# -------------------------------------------------------
# PASO 1 — Git pull silencioso del vault
# -------------------------------------------------------
if (Test-Path "$VAULT\.git") {
    Push-Location $VAULT
    git pull --rebase --quiet 2>$null | Out-Null
    Pop-Location
}

# -------------------------------------------------------
# PASO 2 — Crear log de sesion (una vez por hora)
# -------------------------------------------------------
if (-not (Test-Path $SESSIONS_DIR)) {
    New-Item -ItemType Directory -Path $SESSIONS_DIR -Force | Out-Null
}

$cwd     = (Get-Location).Path
$project = Split-Path $cwd -Leaf

if (-not (Test-Path $outFile)) {
    $content = @"
---
type: session
created: $date $hour
status: active
tags: [session-log, auto-generated]
project: $project
---

# Sesion: $date $hour

## Proyecto activo
- **Directorio**: $cwd
- **Inicio**: $hour

## Tareas de esta sesion
<!-- Se llena durante la sesion -->

## Decisiones tomadas
<!-- Se llena durante la sesion o con /auto-learn al final -->

## Errores resueltos
<!-- Se llena durante la sesion o con /auto-learn al final -->

## Siguiente sesion
<!-- Pendientes para la proxima vez -->
"@
    Set-Content -Path $outFile -Value $content -Encoding UTF8
}

# -------------------------------------------------------
# PASO 3 — Construir systemMessage con contexto del vault
# -------------------------------------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ctx = [System.Text.StringBuilder]::new()

# Proyectos activos desde Dashboard.md
$dashPath = "$VAULT\00-dashboard\Dashboard.md"
if (Test-Path $dashPath) {
    $dash = Get-Content $dashPath -Raw -Encoding UTF8
    if ($dash -match '(?s)### Proyectos activos\r?\n(.*?)(?=\r?\n###)') {
        $block = $Matches[1]
        $projects = $block -split "`n" |
            Where-Object { $_ -match '^\s*-\s*\[\[' } |
            ForEach-Object {
                $name = $_ -replace '\[\[|\]\]', '' -replace '^\s*-\s*', ''
                if ($name -match '^([^\s]+)') { $name = $Matches[1] }
                $name.Trim()
            } |
            Where-Object { $_ -and -not ($_ -match '^reference-') }
        if ($projects.Count -gt 0) {
            [void]$ctx.Append("PROYECTOS ACTIVOS: $($projects -join ', '). ")
        }
    }
}

# Pendientes de sesion anterior
$sessions = Get-ChildItem "$SESSIONS_DIR\*.md" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending
$prevSession = $sessions | Where-Object { $_.Name -ne "$timestamp.md" } | Select-Object -First 1
if ($prevSession) {
    $prevContent = Get-Content $prevSession.FullName -Raw -ErrorAction SilentlyContinue
    if ($prevContent -match '(?s)## Siguiente sesion\r?\n(.*?)(?:\r?\n---|$)') {
        $pendientes = $Matches[1].Trim() -replace '<!--.*?-->', '' -replace '\s+', ' '
        if ($pendientes.Length -gt 10) {
            $pendientes = $pendientes.Substring(0, [Math]::Min(200, $pendientes.Length))
            [void]$ctx.Append("PENDIENTES: $pendientes. ")
        }
    }
}

# Proyecto actual
[void]$ctx.Append("DIRECTORIO: $project.")

$msg = "Obsidian sync OK ($date $hour). $($ctx.ToString())"
@{ systemMessage = $msg } | ConvertTo-Json -Compress

exit 0
