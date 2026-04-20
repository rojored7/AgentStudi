#!/bin/bash
# ============================================================
# AgentStudi - Instalador del agente Generador de Cursos
# Para Claude Code (claude.ai/code)
# ============================================================

set -euo pipefail

AGENT_NAME="generador-de-cursos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/${AGENT_NAME}"

# Detectar OS y ruta de destino
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    CLAUDE_DIR="${USERPROFILE}/.claude"
else
    CLAUDE_DIR="${HOME}/.claude"
fi

TARGET_DIR="${CLAUDE_DIR}/agents/${AGENT_NAME}"

echo ""
echo "=== AgentStudi - Instalador ==="
echo ""
echo "Agente:  ${AGENT_NAME}"
echo "Origen:  ${SOURCE_DIR}"
echo "Destino: ${TARGET_DIR}"
echo ""

# Verificar que el directorio fuente existe
if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "ERROR: No se encontro el directorio del agente: ${SOURCE_DIR}"
    echo "Asegurate de ejecutar este script desde la raiz del repo."
    exit 1
fi

# Verificar que agent.md existe
if [[ ! -f "${SOURCE_DIR}/agent.md" ]]; then
    echo "ERROR: No se encontro agent.md en ${SOURCE_DIR}"
    exit 1
fi

# Crear directorio de agentes si no existe
mkdir -p "${CLAUDE_DIR}/agents"

# Si ya existe, preguntar si sobreescribir
if [[ -d "${TARGET_DIR}" ]]; then
    echo "El agente ya esta instalado en ${TARGET_DIR}"
    read -p "Sobreescribir? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Instalacion cancelada."
        exit 0
    fi
    rm -rf "${TARGET_DIR}"
fi

# Copiar agente
cp -r "${SOURCE_DIR}" "${TARGET_DIR}"

# Verificar instalacion
INSTALLED_FILES=$(find "${TARGET_DIR}" -type f | wc -l)

echo ""
echo "=== Instalacion completada ==="
echo ""
echo "Archivos instalados: ${INSTALLED_FILES}"
echo "Ubicacion: ${TARGET_DIR}"
echo ""
echo "Uso:"
echo "  1. Abre Claude Code en cualquier proyecto"
echo "  2. Escribe: /gen-curso"
echo "  3. Sigue el cuestionario interactivo"
echo ""
echo "Para desinstalar:"
echo "  rm -rf ${TARGET_DIR}"
echo ""
