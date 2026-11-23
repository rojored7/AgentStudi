# ============================================================
# AgentStudi - Desinstalador del Generador de Cursos (Windows)
# Quita el agente y la skill /gen-curso.
# Destino: $env:CLAUDE_CONFIG_DIR si esta definido, si no %USERPROFILE%\.claude
# ============================================================
$ErrorActionPreference = 'Stop'

if ($env:CLAUDE_CONFIG_DIR) { $ClaudeDir = $env:CLAUDE_CONFIG_DIR } else { $ClaudeDir = Join-Path $env:USERPROFILE '.claude' }

$targets = @(
    (Join-Path (Join-Path $ClaudeDir 'agents') 'generador-de-cursos'),
    (Join-Path (Join-Path $ClaudeDir 'skills') 'gen-curso')
)

foreach ($target in $targets) {
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
        Write-Host "Eliminado: $target"
    } else {
        Write-Host "No estaba instalado: $target"
    }
}
exit 0
