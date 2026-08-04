# Memoria — BateaXest (Cuaderno de Batea)
<!-- Mantenida por Claude. Última actualización: 2026-08-04 -->
<!-- PRIMERA PASADA: deducida del repo, sin verificar con el usuario.
     Las secciones "Callejones sin salida" y parte de "Estado actual" están vacías
     porque esa información no está en el código — hay que preguntarla. -->

## Qué es esto

App de cuaderno de campo para gestionar bateas de mejillón: plano de cuerdas por batea,
operaciones (siembra, desdoble, venta, movimiento, ajuste), trazabilidad por lotes,
alertas de edad y registro de ventas con cobro. PWA instalable, en español, uso móvil.

## Mapa

Todo el proyecto es **un solo archivo**: `index.html` (~1600 líneas). No hay build ni `src/`.
Anclas buscables dentro de él, en orden de aparición:

| Zona | Ancla |
|---|---|
| Carga de React/Babel/Firebase por CDN | cabecera `<head>`, buscar `babel-standalone` |
| Config Firebase + override | `FIREBASE_CONFIG`, `CONFIG_KEY` (~L19) |
| Paleta y categorías de cuerda | `const C`, `const CAT` (~L33) |
| Constantes de negocio | `DESCT`, `IVA`, `totalVenta`, `LIM_PROD`, `LIM_MESES_DEFECTO` (~L47-88) |
| Modelo de batea y cálculos | `nuevaBatea`, `stock`, `ocup`, `libres`, `exceso` (~L62-82) |
| Datos semilla | `function seed`, `seedBateas` (~L106) |
| Cuadrícula interactiva (táctil) | `function Grid` (~L184) |
| Pantalla de config Firebase | `function ConfigSetup` (~L269) |
| Login y errores de auth | `function Login`, `mensajeErrorAuth` (~L97, ~L325) |
| Arranque e init de Firebase | `function Root` (~L354) |
| Componente principal (casi toda la app) | `function GestionBatea` (~L377 → final) |
| Persistencia Firestore | `docRef`, `onSnapshot`, `hydratedRef`, `lastSyncRef` (~L391-435) |
| Deshacer multinivel | `pushHistorial`, `deshacerUltimo`, `MAX_UNDO` (~L556) |
| Alta/edición de operaciones | `registrarLote`, `confirmarFase`, `borrarOp` (~L572-733) |
| Alertas de edad | `alertasEdad` (~L635) |
| Exportación CSV | `descargarCSV` (~L51) |

## Decisiones vigentes

- **Un único archivo `index.html`, sin build** (2026-08) — React 18 UMD + Babel standalone
  por CDN, JSX transpilado en el navegador. Se edita el HTML directamente; no hay npm,
  bundler ni linter. Descartado montar toolchain: prioriza poder abrir y desplegar el
  archivo tal cual. Coste asumido: transpilación en cada carga y cero comprobación estática.

- **Todo el estado en un solo documento Firestore `cuaderno/estado`** (2026-08) — lectura
  por `onSnapshot`, escritura del payload completo con `set()` y debounce de 600 ms.
  `lastSyncRef` compara el JSON antes de escribir para no realimentar el ciclo
  snapshot → set → snapshot. Simplifica mucho el código a cambio de los límites de
  concurrencia y tamaño anotados en Trampas.

- **Claves de Firebase hardcodeadas y públicas a propósito** (2026-08, commit `7d89fbb`) —
  hay un comentario explícito en `FIREBASE_CONFIG`: la seguridad la dan el login y las
  reglas de Firestore, no ocultar la config. No tratarlo como fuga de credenciales.
  Se puede sobreescribir desde la pantalla de configuración; queda en localStorage
  bajo `batea_firebase_config`.

- **Deshacer por snapshots completos, no por diffs** (2026-08) — `pushHistorial` clona
  bateas/ops/ventas enteros, pila de `MAX_UNDO` = 20. Simple y robusto; a cambio, cada
  paso de deshacer guarda una copia entera del estado en memoria.

- **Siembra automática con datos de ejemplo** si el documento no existe, en vez de
  pantalla de estado vacío.

## Callejones sin salida

<!-- Vacío: no hay rastro en el repo de qué se intentó y falló. Preguntar al usuario y
     rellenar. Esta es la sección más valiosa del archivo, porque no se recupera leyendo. -->

## Trampas

- **Edición simultánea desde dos dispositivos**: al guardarse el documento entero, el
  último `set()` pisa por completo lo del otro. No hay merge por campo ni transacción.

- **Techo de 1 MiB por documento en Firestore**: `ops` y `ventas` crecen sin poda dentro
  del mismo doc. Ese es el límite real de vida de la app, y llegará sin aviso previo.

- **El efecto de guardado es delicado**: depende de `hydratedRef` y de la comparación con
  `lastSyncRef`. Tocarlo sin entender ambos guardas puede provocar un bucle de escrituras.

- **Sin comprobación estática**: un error de JSX no aparece hasta ejecutar en el navegador,
  y Babel standalone lo reporta en consola, no en pantalla. Tras editar, cargar la página
  y mirar la consola es parte del ciclo, no un extra.

- **`borrarBatea` pierde el inventario de cuerdas** pero conserva operaciones y ventas
  históricas (hay un `flash` que lo avisa, ~L471).

- **`borrarOp` no modifica el plano**, solo el registro; y si la operación tenía venta
  vinculada, se borra también. Para revertir el plano hay que usar Deshacer.

- **Reglas de Firestore fuera del repo**: no hay `firestore.rules` ni `firebase.json` aquí,
  así que no se puede verificar quién puede leer o escribir. Como la config es pública por
  diseño, las reglas son *lo único* que protege los datos. Mientras el usuario no confirme
  que están cerradas, tratarlo como no verificado.

- **Constantes de negocio con valores reales** (`DESCT` 4.38 %, `IVA` 10.5 %, `LIM_PROD`
  500 cuerdas, límites de meses por categoría). No son placeholders: cambiarlas altera
  cálculos de dinero y alertas.

## Estado actual

- **En curso:** rama `claude/installed-skills-qml3tr` — instalación de la skill
  `memoria-proyecto` y su hook. No toca la app.
- **Últimos trabajos** (`git log`): PWA (manifest + iconos), icono rediseñado, arreglo de
  desbordamiento horizontal en móvil, arreglo de pantalla en blanco al registrar operación
  sobre bateas creadas por el usuario, Firebase hardcodeado.
- **Pendiente:** por confirmar con el usuario.
- **Bloqueado / a verificar:** estado de las reglas de Firestore (ver Trampas).

## Preferencias en este proyecto

- Cambios incrementales sobre la arquitectura existente. No proponer rediseños ni añadir
  toolchain sin que lo pida: la decisión de archivo único está tomada a conciencia.
- Ante dudas sobre si algo ya se resolvió, preguntar o decir que no hay datos suficientes,
  en vez de dar por hecho un progreso no confirmado.
- Ojo al aplicar la skill `mejillon-stack`: describe el stack de Marea y reparto-mejillón
  (Supabase + Vercel). **BateaXest usa Firebase y no comparte backend con ellas.**
