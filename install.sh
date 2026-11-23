#!/usr/bin/env bash
# ============================================================
# AgentStudi - Instalador del Generador de Cursos para Claude Code
# Instala el agente y la skill /gen-curso, y verifica cada archivo.
#
# Uso:  bash install.sh        pregunta antes de sobrescribir
#       bash install.sh -y     sin preguntas
# Destino: $CLAUDE_CONFIG_DIR si esta definido, si no ~/.claude
# ============================================================
set -euo pipefail

AGENT_NAME="generador-de-cursos"
SKILL_NAME="gen-curso"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_SRC="${SCRIPT_DIR}/${AGENT_NAME}"
SKILL_SRC="${SCRIPT_DIR}/${SKILL_NAME}"

ASSUME_YES=0
for arg in "$@"; do
    case "${arg}" in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}"; exit 0 ;;
        *) echo "ERROR: opcion desconocida: ${arg}"; exit 2 ;;
    esac
done

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
AGENT_DST="${CLAUDE_DIR}/agents/${AGENT_NAME}"
SKILL_DST="${CLAUDE_DIR}/skills/${SKILL_NAME}"

echo ""
echo "=== AgentStudi - Instalador ==="
echo "Claude:  ${CLAUDE_DIR}"
echo "Agente:  ${AGENT_DST}"
echo "Skill:   ${SKILL_DST}"
echo ""

for required in "${AGENT_SRC}/agent.md" "${SKILL_SRC}/SKILL.md"; do
    if [[ ! -f "${required}" ]]; then
        echo "ERROR: falta ${required}. Ejecuta el script desde un clon completo del repo."
        exit 1
    fi
done

if [[ -d "${AGENT_DST}" || -d "${SKILL_DST}" ]] && [[ "${ASSUME_YES}" -ne 1 ]]; then
    if [[ ! -t 0 ]]; then
        echo "ERROR: ya hay una instalacion y no hay terminal para confirmar. Usa: bash install.sh -y"
        exit 1
    fi
    read -r -p "Ya existe una instalacion. Sobrescribir? (s/n): " reply
    if [[ ! "${reply}" =~ ^[Ss]$ ]]; then
        echo "Instalacion cancelada."
        exit 0
    fi
fi

install_dir() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "${dst}")"
    rm -rf "${dst}"
    cp -R "${src}" "${dst}"
}

install_dir "${AGENT_SRC}" "${AGENT_DST}"
install_dir "${SKILL_SRC}" "${SKILL_DST}"

# Verificacion: cada archivo del repo existe en destino con el mismo sha256, y no sobra ninguno
verify_dir() {
    local src="$1" dst="$2" errors=0 rel
    while IFS= read -r -d '' file; do
        rel="${file#"${src}"/}"
        if [[ ! -f "${dst}/${rel}" ]]; then
            echo "FALTA: ${dst}/${rel}"
            errors=$((errors + 1))
        elif [[ "$(sha256sum < "${file}")" != "$(sha256sum < "${dst}/${rel}")" ]]; then
            echo "DIFIERE: ${dst}/${rel}"
            errors=$((errors + 1))
        fi
    done < <(find "${src}" -type f -print0)
    local n_src n_dst
    n_src="$(find "${src}" -type f | wc -l)"
    n_dst="$(find "${dst}" -type f | wc -l)"
    if [[ "${n_src}" -ne "${n_dst}" ]]; then
        echo "SOBRAN archivos en ${dst}: ${n_dst} instalados, ${n_src} en el repo"
        errors=$((errors + 1))
    fi
    echo "${dst}: ${n_dst} archivos"
    return "${errors}"
}

ERRORS=0
verify_dir "${AGENT_SRC}" "${AGENT_DST}" || ERRORS=$((ERRORS + $?))
verify_dir "${SKILL_SRC}" "${SKILL_DST}" || ERRORS=$((ERRORS + $?))

if [[ "${ERRORS}" -gt 0 ]]; then
    echo ""
    echo "ERROR: la verificacion encontro ${ERRORS} problema(s). La instalacion no es confiable."
    exit 1
fi

echo ""
echo "=== Instalacion completada y verificada ==="
echo "Abre Claude Code en cualquier proyecto y escribe: /gen-curso"
echo "Para desinstalar: bash uninstall.sh"
echo ""
