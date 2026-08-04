---
name: memoria-proyecto
description: 'Memoria persistente por proyecto que permite retomar el trabajo donde se dejó sin releer el código entero ni volver a deducir la arquitectura, las decisiones ya tomadas o lo que ya se intentó y falló. Úsala SIEMPRE al empezar a trabajar en un repo, ANTES de explorar o leer archivos, y otra vez en cuanto aparezca algo memorable: una decisión de diseño y su porqué, un intento fallido, una trampa del entorno, un cambio en lo que está a medias. Actívala también ante "sigue por donde íbamos", "¿en qué estábamos?", "retoma", "continúa", "ponte al día", "recuerda que...", "apunta esto", "esto ya lo probamos", o cuando el usuario se extrañe de que no recuerdes algo de una sesión anterior. Ante la duda al abrir un proyecto, aplícala: leer la memoria cuesta mucho menos que reconstruir el contexto.'
---

# Memoria de proyecto

## Por qué existe

El código es un registro de **qué** hace el sistema, no de **por qué** es así. Releerlo entero reconstruye lo primero y nada de lo segundo, y cuesta una fortuna en tokens y tiempo.

Cada sesión nueva se pierden dos cosas distintas:

1. **Lo recuperable pero caro.** Dónde vive cada cosa, cómo encajan las piezas. Se puede releer, pero se paga cada vez.
2. **Lo irrecuperable.** Por qué se decidió así, qué se probó y no funcionó, qué quedó a medias, qué muerde. Ningún volumen de lectura lo devuelve: no está escrito en el código.

La memoria ataca las dos. Para lo primero guarda un mapa que evita explorar a ciegas. Para lo segundo es la única copia que existe.

## Dónde vive

`.claude/MEMORIA.md` en la raíz del repo, **commiteada**. Un archivo por repo: cada proyecto recuerda lo suyo.

Que esté commiteada no es un detalle de estilo. En Claude Code web el contenedor se destruye al acabar la sesión y el repo se vuelve a clonar limpio. Lo que no está en git no existe la próxima vez — una memoria sin commitear ya está perdida.

## El ciclo

**Leer** (al abrir) → **usar** (en lugar de explorar) → **escribir** (en cuanto pasa algo) → **commitear** (siempre).

### 1. Leer antes de tocar nada

Primer acto al empezar a trabajar en un repo: leer `.claude/MEMORIA.md` entera. Es corta por diseño. Si no existe, ve a *Arranque en frío*.

Y aquí es donde la skill se paga: **deja que la memoria sustituya a la exploración**. Si el mapa dice dónde está la lógica de reparto, ve directo con una lectura acotada. No repitas el `grep` que ya se hizo la vez anterior — ese es exactamente el gasto que la memoria existe para evitar.

### 2. Escribir en el momento, no al final

La tentación es "lo apunto cuando terminemos". Es mala idea: las sesiones se cortan, se quedan sin contexto o el contenedor muere antes del cierre. Lo que no se apuntó cuando ocurrió, se pierde.

En cuanto pase algo de las categorías de abajo, actualiza la entrada. Son dos líneas, no un ritual.

### 3. Commitear

Cambio de memoria sin commit es un cambio perdido. Va en el mismo commit del trabajo que lo motivó, o en uno propio (`docs: actualizar memoria del proyecto`) si no hubo cambio de código.

## Qué guardar y qué no

El criterio es una sola pregunta: **¿se recuperaría releyendo el código?**

- Sí, y es barato → no lo guardes.
- Sí, pero encontrarlo es caro → guarda el ancla, no el contenido.
- No → guárdalo. Eres la única copia.

| Guardar | Por qué |
|---|---|
| Decisiones y su porqué | El código enseña la opción elegida y borra las descartadas. Sin esto se re-discute lo ya cerrado o, peor, se "arregla" algo que era deliberado. |
| Callejones sin salida | Lo más irrecuperable que hay: un intento fallido no deja rastro en el repo. Sin esto se reintenta lo que ya falló. |
| Mapa de navegación | Convierte "grep a ciegas por cinco archivos" en "abre esto por aquí". |
| Trampas | Lo que muerde sin avisar: quirks del entorno, del build, datos con forma rara. |
| Estado en curso | Qué está a medias, qué falta, qué bloquea. Es la respuesta a "¿por dónde íbamos?". |
| Preferencias del usuario aquí | Cómo quiere que se trabaje en **este** proyecto concreto. |

| No guardar | Por qué |
|---|---|
| Resumen de lo que hace el código | Se relee cuando haga falta. Y se desincroniza en silencio, que es peor que no tenerlo. |
| Narración de la sesión | "Primero hice X, luego Y" no sirve para retomar. Guarda el poso, no el diario. |
| Fragmentos de código copiados | La fuente está en el repo. Copiarla crea una segunda versión que acabará mintiendo. |
| Obviedades del stack | "Usa React" se ve en `package.json` en dos segundos. |

## Anclar sin que caduque

**Ancla en nombres, no en números de línea.** Un número de línea caduca en la primera edición; un nombre de función o una cadena única sobrevive a casi todo y además es buscable.

- Bien: `index.html — cálculo del reparto, buscar repartirProduccion()`
- Mal: `index.html línea 1240`

En archivos muy grandes un número aproximado ayuda a orientar, pero siempre acompañado del ancla buscable: `~L1240, buscar repartirProduccion()`.

## Contra la obsolescencia

Una memoria que miente es peor que no tener memoria: hace actuar con confianza sobre algo falso, y por eso mismo ni se comprueba. Tres reglas la mantienen honesta:

1. **Corregir al vuelo.** Si al usar una entrada resulta que no cuadra con el código, arréglala en ese momento. Dejarlo "para luego" es como se pudre una memoria.
2. **Fechar lo que puede caducar.** Estado y decisiones llevan fecha. Una entrada de hace seis meses se lee con más escepticismo que una de ayer.
3. **Verificar antes de apoyar peso.** Orientarse con la memoria es gratis. Apoyarse en ella para construir encima exige confirmarla antes con una lectura acotada.

## Presupuesto

Unas 150-200 líneas. Si crece mucho más, la memoria empieza a costar lo que ahorra y hay que podarla.

Al podar, el criterio es la irrecuperabilidad:

- **Se va primero:** decisiones ya evidentes en el código que nadie cuestiona, y estado ya completado.
- **Se queda casi siempre:** callejones sin salida y trampas. No están escritos en ningún otro sitio.

## Relación con CLAUDE.md

- `CLAUDE.md` — instrucciones estables. *Cómo* se trabaja aquí. Cambia poco.
- `.claude/MEMORIA.md` — estado que evoluciona. *Qué* ha pasado y por qué. Cambia cada sesión.

No dupliques entre los dos. Si algo es una norma permanente, su sitio es `CLAUDE.md`.

## Plantilla

Usa esta estructura. Las secciones fijas permiten localizar dónde escribir sin releer el archivo entero, y una sección vacía es información: dice que ahí todavía no se sabe nada.

```markdown
# Memoria — <nombre del proyecto>
<!-- Mantenida por Claude. Última actualización: AAAA-MM-DD -->

## Qué es esto
Una o dos frases: qué hace y para quién.

## Mapa
Dónde vive cada cosa, solo lo que cuesta encontrar. Ancla en nombres buscables.

## Decisiones vigentes
- **<decisión>** (AAAA-MM-DD) — por qué. Qué se descartó y por qué.

## Callejones sin salida
- **<lo que se intentó>** (AAAA-MM-DD) — cómo falló. No reintentar sin información nueva.

## Trampas
- <lo que muerde y cómo esquivarlo>

## Estado actual
- **En curso:** …
- **Pendiente:** …
- **Bloqueado:** … (por qué / qué lo desbloquearía)

## Preferencias en este proyecto
- <cómo quiere el usuario que se trabaje aquí>
```

## Arranque en frío

Primera vez en un repo sin memoria. No hagas una lectura exhaustiva: sería pagar justo el coste que esta skill evita. Pasada dirigida:

1. Estructura (`git ls-files`), README y manifiestos de dependencias.
2. `git log --oneline -30`. Los mensajes de commit revelan el trabajo reciente y qué problemas dio.
3. Abre solo los dos o tres archivos que claramente concentran la lógica.
4. Escribe la memoria y marca en el encabezado que es una primera pasada sin verificar.
5. **Pregunta al usuario lo que no se deduce del repo:** decisiones y su porqué, qué se intentó sin éxito, qué está a medias. Eso solo lo sabe él, y es la parte más valiosa del archivo.
6. Commit.

Saldrá incompleta, y es lo correcto. La memoria se gana con el uso; no se escribe de golpe el primer día.

## Carga automática

El hook `SessionStart` de `assets/` vuelca la memoria en contexto al arrancar la sesión, sin que nadie tenga que pedirlo. Para instalarlo en un repo:

```bash
mkdir -p .claude/hooks
cp assets/session-start-memoria.sh .claude/hooks/
chmod +x .claude/hooks/session-start-memoria.sh
```

Y registrarlo en `.claude/settings.json` (fusionar si el archivo ya existe, sin pisar hooks previos):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start-memoria.sh"
          }
        ]
      }
    ]
  }
}
```

Ambos archivos se commitean: es lo que hace que la carga automática siga viva en el siguiente contenedor.

El hook cubre la lectura, no la escritura. Mantener la memoria al día sigue siendo trabajo de esta skill.
