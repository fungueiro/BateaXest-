#!/bin/bash
# Vuelca la memoria del proyecto en el contexto al arrancar la sesión.
# Lo que este script imprime en stdout lo lee Claude antes del primer turno.
set -uo pipefail

RAIZ="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
MEMORIA="$RAIZ/.claude/MEMORIA.md"

if [ ! -f "$MEMORIA" ]; then
  echo "No hay memoria de proyecto en .claude/MEMORIA.md."
  echo "Si esta sesión implica trabajo real sobre el repo, usa la skill 'memoria-proyecto'"
  echo "(sección «Arranque en frío») para crearla antes de explorar el código a ciegas."
  exit 0
fi

echo "=== MEMORIA DEL PROYECTO (.claude/MEMORIA.md) ==="
echo
cat "$MEMORIA"
echo
echo "=== FIN DE LA MEMORIA ==="
echo
echo "Úsala en lugar de reexplorar: ve directo a las anclas del mapa con lecturas acotadas."
echo "Actualízala en cuanto aparezca una decisión, un intento fallido, una trampa o un cambio"
echo "de estado — en el momento, no al final — y commitea el cambio antes de cerrar."
