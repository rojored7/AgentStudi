# AgentStudi - Generador de Cursos para Claude Code

Agente para generar cursos tecnicos completos desde Claude Code con el comando `/gen-curso`.

## Que hace

Genera cursos completos con:
- Contenido teorico con ejemplos de codigo y diagramas
- Laboratorios practicos (Python, Bash, JavaScript)
- Evaluaciones sin preguntas repetidas entre modulos
- Validacion de calidad: links verificados con WebFetch, tablas sin filas vacias, preguntas duplicadas
- Archivos seed listos para importar a la plataforma LMS

## Instalacion

Se instalan dos piezas, y las dos son necesarias para que `/gen-curso` funcione:

| Pieza | Destino |
|---|---|
| Agente | `~/.claude/agents/generador-de-cursos/` |
| Skill `/gen-curso` | `~/.claude/skills/gen-curso/` |

```bash
git clone https://github.com/rojored7/AgentStudi.git
cd AgentStudi
```

Linux, macOS o Windows con Git Bash:

```bash
bash install.sh          # pregunta antes de sobrescribir una instalacion existente
bash install.sh -y       # sin preguntas
```

Windows con PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1          # pregunta antes de sobrescribir
powershell -ExecutionPolicy Bypass -File install.ps1 -Yes     # sin preguntas
```

El instalador compara el sha256 de cada archivo instalado contra el repo y termina con error si falta, difiere o sobra alguno.
Si `CLAUDE_CONFIG_DIR` esta definido, instala ahi en lugar de `~/.claude`.

Para actualizar en un PC que ya lo tiene:

```bash
git pull
bash install.sh -y       # o install.ps1 -Yes
```

Reinicia Claude Code despues de instalar para que cargue la skill.

## Uso

Desde cualquier proyecto en Claude Code:

```
/gen-curso
/gen-curso ciberseguridad
```

El agente sigue un flujo interactivo de 6 fases:

1. **Cuestionario** - preguntas para definir el curso
2. **Investigacion** - busqueda de fuentes oficiales
3. **Estructura** - modulos, lecciones y labs
4. **Contenido** - teoria, labs y evaluaciones
5. **Validacion** - links, tablas, preguntas duplicadas y formato
6. **Seed** - archivos para importar a la base de datos

El contenido generado queda en `contenidos/` del proyecto actual y los checkpoints en `.claude/checkpoint-*.json`.

## Estructura del repo

```
gen-curso/
└── SKILL.md                    # Skill /gen-curso (apunta al agente)
generador-de-cursos/
├── agent.md                    # Definicion principal del agente
├── README.md                   # Documentacion interna
├── skills/
│   ├── cuestionario.md         # Entrevista interactiva
│   ├── investigacion.md        # Busqueda de fuentes
│   ├── estructura.md           # Arquitectura del curso
│   ├── contenido.md            # Generacion de lecciones
│   ├── laboratorios.md         # Labs practicos
│   ├── evaluaciones.md         # Quizzes sin duplicados entre modulos
│   ├── validacion.md           # Control de calidad
│   └── seed.md                 # Seed para la base de datos
└── templates/
    ├── lesson-surface.md       # Template nivel basico
    ├── lesson-deep.md          # Template nivel intermedio
    ├── lesson-expert.md        # Template nivel experto
    └── seed.ts.template        # Template de seed TypeScript
install.sh / install.ps1        # Instaladores con verificacion
uninstall.sh / uninstall.ps1    # Desinstaladores
tests/test-install.sh           # Prueba de instalacion en un directorio temporal
```

## Pruebas del instalador

```bash
bash tests/test-install.sh        # instalador bash
bash tests/test-install.sh ps1    # instalador PowerShell (Windows)
```

Instala en un directorio temporal, compara contra el repo, prueba la reinstalacion y la desinstalacion.

## Requisitos

- [Claude Code](https://claude.ai/code) instalado
- Conexion a internet (fase de investigacion y verificacion de links)

## Desinstalacion

```bash
bash uninstall.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

## Licencia

MIT
