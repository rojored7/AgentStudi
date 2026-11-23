#!/usr/bin/env bash
# ============================================================
# AgentStudi - Desinstalador del Generador de Cursos
# Quita el agente y la skill /gen-curso.
# Destino: $CLAUDE_CONFIG_DIR si esta definido, si no ~/.claude
# ============================================================
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"

for target in "${CLAUDE_DIR}/agents/generador-de-cursos" "${CLAUDE_DIR}/skills/gen-curso"; do
    if [[ -e "${target}" ]]; then
        rm -rf "${target}"
        echo "Eliminado: ${target}"
    else
        echo "No estaba instalado: ${target}"
    fi
done
