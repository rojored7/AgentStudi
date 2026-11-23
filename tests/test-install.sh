#!/usr/bin/env bash
# Prueba de instalacion y desinstalacion en un directorio de Claude temporal.
# Uso: bash tests/test-install.sh            (instalador bash)
#      bash tests/test-install.sh ps1        (instalador PowerShell, solo Windows)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-sh}"
TMP_CLAUDE="$(mktemp -d)"
trap 'rm -rf "${TMP_CLAUDE}"' EXIT

FAILS=0
fail() { echo "FALLO: $*"; FAILS=$((FAILS + 1)); }

run_install() {
    if [[ "${MODE}" == "ps1" ]]; then
        CLAUDE_CONFIG_DIR="$(cygpath -w "${TMP_CLAUDE}")" powershell.exe -NoProfile -ExecutionPolicy Bypass \
            -File "$(cygpath -w "${REPO_DIR}/install.ps1")" -Yes
    else
        CLAUDE_CONFIG_DIR="${TMP_CLAUDE}" bash "${REPO_DIR}/install.sh" -y
    fi
}

run_uninstall() {
    if [[ "${MODE}" == "ps1" ]]; then
        CLAUDE_CONFIG_DIR="$(cygpath -w "${TMP_CLAUDE}")" powershell.exe -NoProfile -ExecutionPolicy Bypass \
            -File "$(cygpath -w "${REPO_DIR}/uninstall.ps1")"
    else
        CLAUDE_CONFIG_DIR="${TMP_CLAUDE}" bash "${REPO_DIR}/uninstall.sh"
    fi
}

compare_tree() {
    local src="$1" dst="$2"
    if [[ ! -d "${dst}" ]]; then
        fail "no existe ${dst}"
        return
    fi
    if ! diff -rq "${src}" "${dst}"; then
        fail "${dst} no coincide con ${src}"
    fi
}

# 1. Instalacion limpia
if ! run_install; then
    fail "el instalador termino con error en instalacion limpia"
fi
compare_tree "${REPO_DIR}/generador-de-cursos" "${TMP_CLAUDE}/agents/generador-de-cursos"
compare_tree "${REPO_DIR}/gen-curso" "${TMP_CLAUDE}/skills/gen-curso"

# 1b. Sin -y y sin terminal, sobre instalacion existente: debe negarse sin tocar nada
if [[ "${MODE}" == "ps1" ]]; then
    NEG_CMD=(powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "${REPO_DIR}/install.ps1")")
    NEG_DIR="$(cygpath -w "${TMP_CLAUDE}")"
else
    NEG_CMD=(bash "${REPO_DIR}/install.sh")
    NEG_DIR="${TMP_CLAUDE}"
fi
[[ -d "${TMP_CLAUDE}/agents/generador-de-cursos" ]] && echo "marca" > "${TMP_CLAUDE}/agents/generador-de-cursos/marca.txt"
if CLAUDE_CONFIG_DIR="${NEG_DIR}" "${NEG_CMD[@]}" < /dev/null; then
    fail "sin -y y sin terminal el instalador debia fallar y salio con 0"
fi
[[ -f "${TMP_CLAUDE}/agents/generador-de-cursos/marca.txt" ]] || fail "sin -y el instalador toco la instalacion existente"

# 2. Reinstalacion no interactiva sobre una instalacion existente con un archivo extra
[[ -d "${TMP_CLAUDE}/agents/generador-de-cursos" ]] && echo "basura" > "${TMP_CLAUDE}/agents/generador-de-cursos/sobrante.txt"
if ! run_install; then
    fail "el instalador termino con error al reinstalar"
fi
if [[ -e "${TMP_CLAUDE}/agents/generador-de-cursos/sobrante.txt" ]]; then
    fail "la reinstalacion dejo un archivo que no es del repo"
fi
compare_tree "${REPO_DIR}/generador-de-cursos" "${TMP_CLAUDE}/agents/generador-de-cursos"

# 3. Desinstalacion
if ! run_uninstall; then
    fail "el desinstalador termino con error"
fi
[[ -e "${TMP_CLAUDE}/agents/generador-de-cursos" ]] && fail "quedo el agente tras desinstalar"
[[ -e "${TMP_CLAUDE}/skills/gen-curso" ]] && fail "quedo la skill tras desinstalar"

if [[ "${FAILS}" -gt 0 ]]; then
    echo "RESULTADO (${MODE}): ${FAILS} fallo(s)"
    exit 1
fi
echo "RESULTADO (${MODE}): OK"
