# ============================================================
# AgentStudi - Instalador del Generador de Cursos para Claude Code (Windows)
# Instala el agente y la skill /gen-curso, y verifica cada archivo.
#
# Uso:  powershell -ExecutionPolicy Bypass -File install.ps1        pregunta antes de sobrescribir
#       powershell -ExecutionPolicy Bypass -File install.ps1 -Yes   sin preguntas
# Destino: $env:CLAUDE_CONFIG_DIR si esta definido, si no %USERPROFILE%\.claude
# ============================================================
param([switch]$Yes)

$ErrorActionPreference = 'Stop'

$AgentName = 'generador-de-cursos'
$SkillName = 'gen-curso'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentSrc = Join-Path $ScriptDir $AgentName
$SkillSrc = Join-Path $ScriptDir $SkillName

if ($env:CLAUDE_CONFIG_DIR) { $ClaudeDir = $env:CLAUDE_CONFIG_DIR } else { $ClaudeDir = Join-Path $env:USERPROFILE '.claude' }
$AgentDst = Join-Path (Join-Path $ClaudeDir 'agents') $AgentName
$SkillDst = Join-Path (Join-Path $ClaudeDir 'skills') $SkillName

Write-Host ''
Write-Host '=== AgentStudi - Instalador ==='
Write-Host "Claude:  $ClaudeDir"
Write-Host "Agente:  $AgentDst"
Write-Host "Skill:   $SkillDst"
Write-Host ''

foreach ($required in @((Join-Path $AgentSrc 'agent.md'), (Join-Path $SkillSrc 'SKILL.md'))) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        Write-Host "ERROR: falta $required. Ejecuta el script desde un clon completo del repo."
        exit 1
    }
}

if (((Test-Path -LiteralPath $AgentDst) -or (Test-Path -LiteralPath $SkillDst)) -and -not $Yes) {
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) {
        Write-Host 'ERROR: ya hay una instalacion y no hay terminal para confirmar. Usa: install.ps1 -Yes'
        exit 1
    }
    $reply = Read-Host 'Ya existe una instalacion. Sobrescribir? (s/n)'
    if ($reply -notmatch '^[Ss]$') {
        Write-Host 'Instalacion cancelada.'
        exit 0
    }
}

function Install-Dir([string]$Src, [string]$Dst) {
    $parent = Split-Path -Parent $Dst
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    if (Test-Path -LiteralPath $Dst) { Remove-Item -LiteralPath $Dst -Recurse -Force }
    Copy-Item -LiteralPath $Src -Destination $Dst -Recurse -Force
}

# Verificacion: cada archivo del repo existe en destino con el mismo sha256, y no sobra ninguno
function Test-Dir([string]$Src, [string]$Dst) {
    $errors = 0
    $srcRoot = (Resolve-Path -LiteralPath $Src).Path.TrimEnd('\')
    $srcFiles = @(Get-ChildItem -LiteralPath $Src -Recurse -File -Force)
    foreach ($file in $srcFiles) {
        $rel = $file.FullName.Substring($srcRoot.Length + 1)
        $target = Join-Path $Dst $rel
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            Write-Host "FALTA: $target"
            $errors++
        } elseif ((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash) {
            Write-Host "DIFIERE: $target"
            $errors++
        }
    }
    $dstFiles = @(Get-ChildItem -LiteralPath $Dst -Recurse -File -Force)
    if ($srcFiles.Count -ne $dstFiles.Count) {
        Write-Host "SOBRAN archivos en ${Dst}: $($dstFiles.Count) instalados, $($srcFiles.Count) en el repo"
        $errors++
    }
    Write-Host "${Dst}: $($dstFiles.Count) archivos"
    return $errors
}

try {
    Install-Dir $AgentSrc $AgentDst
    Install-Dir $SkillSrc $SkillDst
} catch {
    Write-Host "ERROR: no se pudo copiar: $($_.Exception.Message)"
    exit 1
}

$total = (Test-Dir $AgentSrc $AgentDst) + (Test-Dir $SkillSrc $SkillDst)
if ($total -gt 0) {
    Write-Host ''
    Write-Host "ERROR: la verificacion encontro $total problema(s). La instalacion no es confiable."
    exit 1
}

Write-Host ''
Write-Host '=== Instalacion completada y verificada ==='
Write-Host 'Abre Claude Code en cualquier proyecto y escribe: /gen-curso'
Write-Host 'Para desinstalar: powershell -ExecutionPolicy Bypass -File uninstall.ps1'
Write-Host ''
exit 0
