# AgentStudi - Generador de Cursos para Claude Code

Agente autonomo para generar cursos tecnicos completos con contenido de calidad profesional desde Claude Code.

## Que hace

Genera cursos completos con:
- Contenido teorico con ejemplos de codigo y diagramas
- Laboratorios practicos ejecutables (Python, Bash, JavaScript)
- Evaluaciones tipo MULTIPLE_CHOICE con 4 opciones
- Validacion automatica de sintaxis de todo el codigo generado
- Archivos seed listos para importar a plataforma LMS

## Instalacion

```bash
git clone https://github.com/rojored7/AgentStudi.git
cd AgentStudi
bash install.sh
```

Un solo comando despues del clone:

```bash
bash install.sh
```

El agente queda disponible globalmente en `~/.claude/agents/generador-de-cursos/`.

## Uso

Desde cualquier proyecto en Claude Code:

```
/gen-curso
```

El agente inicia un flujo interactivo de 6 fases:

1. **Cuestionario** - 15 preguntas para definir el curso
2. **Investigacion** - Busqueda automatica de fuentes oficiales
3. **Estructura** - Generacion de modulos, lecciones y labs
4. **Contenido** - Creacion de teoria, labs y evaluaciones
5. **Validacion** - Syntax check de todo el codigo + verificacion de formato
6. **Seed** - Generacion de archivos para importar a DB

## Estructura del agente

```
generador-de-cursos/
├── agent.md                    # Definicion principal del agente
├── README.md                   # Documentacion interna
├── skills/
│   ├── cuestionario.md         # Entrevista interactiva
│   ├── investigacion.md        # Busqueda de fuentes
│   ├── estructura.md           # Arquitectura del curso
│   ├── contenido.md            # Generacion de lecciones
│   ├── laboratorios.md         # Labs con validacion de sintaxis
│   ├── evaluaciones.md         # Quizzes MULTIPLE_CHOICE
│   ├── validacion.md           # Control de calidad
│   └── seed.md                 # Generacion de seed para DB
└── templates/
    ├── lesson-surface.md       # Template nivel basico
    ├── lesson-deep.md          # Template nivel intermedio
    ├── lesson-expert.md        # Template nivel experto
    └── seed.ts.template        # Template de seed TypeScript
```

## Requisitos

- [Claude Code](https://claude.ai/code) instalado
- Conexion a internet (para la fase de investigacion)

## Desinstalacion

```bash
bash uninstall.sh
```

O manualmente:

```bash
rm -rf ~/.claude/agents/generador-de-cursos
```

## Licencia

MIT
