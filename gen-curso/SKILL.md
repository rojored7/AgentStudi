# Skill: gen-curso

Invoca el agente GeneradorDeCursos para crear cursos tecnicos completos de alta calidad.

## Uso

```
/gen-curso [tema opcional]
```

## Que hace este skill

Activa el agente `generador-de-cursos` ubicado en `~/.claude/agents/generador-de-cursos/`.
El agente guia al usuario paso a paso a traves de 6 fases:

1. Cuestionario interactivo (8-12 min)
2. Investigacion automatica de fuentes (3-5 min)
3. Generacion de estructura modular (2-3 min)
4. Creacion de contenido, labs y evaluaciones en paralelo (15-25 min)
5. Validacion de calidad automatica (5-10 min)
6. Generacion de archivos seed para la plataforma LMS (2-3 min)

## Instrucciones para Claude

Cuando el usuario invoca /gen-curso:

1. Leer el archivo completo del agente en `~/.claude/agents/generador-de-cursos/agent.md`
2. Seguir el workflow de 6 fases definido en ese archivo
3. Usar las 8 skills especializadas ubicadas en `~/.claude/agents/generador-de-cursos/skills/`
4. Si el usuario proporciono un tema como argumento, usarlo como punto de partida del cuestionario
5. Si no hay tema, comenzar la Fase 1 con la primera pregunta del cuestionario

## Notas

- El agente guarda checkpoints en `.claude/checkpoint-*.json` para permitir reanudar si se interrumpe
- Todo el contenido generado se guarda en la carpeta `contenidos/` del proyecto actual
- El agente valida sintaxis de codigo, links activos y formato de evaluaciones automaticamente
