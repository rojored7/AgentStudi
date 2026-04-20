#!/bin/bash
# ============================================================
# AgentStudi - Desinstalador del agente Generador de Cursos
# ============================================================

set -euo pipefail

AGENT_NAME="generador-de-cursos"

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    CLAUDE_DIR="${USERPROFILE}/.claude"
else
    CLAUDE_DIR="${HOME}/.claude"
fi

TARGET_DIR="${CLAUDE_DIR}/agents/${AGENT_NAME}"

if [[ ! -d "${TARGET_DIR}" ]]; then
    echo "El agente no esta instalado en ${TARGET_DIR}"
    exit 0
fi

echo "Desinstalando agente de: ${TARGET_DIR}"
rm -rf "${TARGET_DIR}"
echo "Agente desinstalado correctamente."
