# Cuaderno de Batea

App de una sola página (`index.html`, React + Babel en el navegador, datos en Firestore)
para llevar el inventario de cuerdas de mejillón de una batea.

## Anatomía real de una batea

Esto no es una metáfora: la rejilla de la app **es** el emparrillado de la batea. Toda
decisión de diseño de la pantalla debe respetar esta anatomía y este vocabulario.

De abajo arriba:

| Elemento | Apoya en | Orientación | Función |
|---|---|---|---|
| **Flotadores** | — | longitudinales | flotación |
| **Vigas principales** | flotadores | longitudinales | reparten la carga |
| **Vigas** | principales | **transversales** (⊥ principales) | estructura |
| **Puntones** | vigas | longitudinales (⊥ vigas) | **aquí se amarran las cuerdas** |
| **Aleros** (o **látigos**) | extremos de las vigas | longitudinales | cierran el perímetro, uno por costado |

- **Claro**: el hueco entre dos vigas. Una batea de N vigas tiene **N − 1 claros**.
- **Cadena de fondeo**: va **siempre en la primera viga**, en un extremo. Es el origen
  de la numeración: los claros se cuentan 1, 2, 3… alejándose de ella (de proa a popa).
- **Babor / estribor**: el eje longitudinal de la batea parte cada claro en dos mitades.
  Cada mitad es un **medio claro**, y es la unidad de la que se habla: "el 2º claro de
  babor". Vista en planta con la cadena arriba, babor queda a la izquierda.
- Si la batea tiene un **número impar de puntones**, hay uno central por el que baja la
  **cadena**: no es de babor ni de estribor, es el eje, y suele dejar puntos
  inutilizables. Con número par el eje cae entre dos puntones y no hay puntón central.
- **Zonas**: dentro de un medio claro, del alero hacia el eje, se distinguen tres
  tramos por referencias físicas, no por número: **ala**, **entre flotadores** y **medio**.
  No son cortes arbitrarios: **los marcan los propios flotadores**.

Así es como se nombra una cuerda hablando, y así debe leerse el plano:

> "cuerdas del 2º claro de babor" · "3er claro de estribor entre flotadores" ·
> "5º claro de babor del ala"

**Nadie dice "puntón 12".** El eje de puntones no se numera en pantalla: se rotula con
sus referencias (ala, entre flotadores, medio) y con los aleros como borde.

### Dos cuerdas por puntón: proa y popa

En cada claro se amarran **normalmente dos cuerdas por puntón**: una junto a la viga de
**proa** del claro y otra junto a la de **popa**. No es una cantidad, son **dos sitios
distintos** — y a veces se completa solo uno de los dos, así que hay que poder trabajar
"medio claro" también en este sentido:

> "las cuerdas a levantar están en el claro dos y medio del tres de estribor"

Los claros se van llenando de proa a popa o al revés. La capacidad física de la batea no
es, por tanto, el número de claros por puntones: es el doble, y el límite real es el
normativo (500 cuerdas de venta + mexilla, 100 de colectora).

Queda fuera del modelo el caso excepcional de amontonar más de dos en un punto para
**rarearlas** (repartirlas) más adelante; eso hoy cae en `extra`.

En los aleros normalmente no se amarran cuerdas, pero puede hacerse en ciertos momentos.

### Flotadores

Van **longitudinales**, bajo las vigas principales, y son **simétricos**: los mismos
puntones en los dos costados. Una batea lleva 4 (dos por costado) o 6 (tres).

**Encima de un flotador no se puede amarrar**, y el flotador **no recorre la batea
entera**: cubre un tramo de claros, y por delante y por detrás ese mismo puntón sí se
amarra. En el plano es un rectángulo, no una columna.

Pero eso **no se describe con números**: se dibuja. El usuario anula puntos de amarre
sobre el plano y así traza los flotadores, la cadena (que también inutiliza puntones)
y cualquier otro sitio donde no se pueda atar. Un solo gesto para todo, en `bloq`.

Los flotadores se marcan aparte, por puntón, **solo para las zonas**: no anulan nada
por su cuenta. Las **zonas son cosa del ancho** — se hablan igual en todos los claros,
también donde no hay flotador debajo: **ala** del alero al primero, **entre flotadores**
del primero al último, **medio** del último hasta el eje.

## Cómo se refleja en el modelo de datos

El objeto batea (`nuevaBatea`) usa claves `"claro-puntón-mitad"`, que se leen así:

- **claro**, `0` es el pegado a la cadena (el "1er claro" en pantalla)
- **puntón**, de babor (izquierda) a estribor (derecha)
- **mitad**, `0` = la cuerda de proa del claro, `1` = la de popa
- `largo` = nº de claros = **vigas − 1** · `ancho` = nº de puntones
- `flot: [d, …]` = puntones por los que pasa un flotador, contados **desde el alero**
  (`0` = el pegado a él) y simétricos en los dos costados. Solo definen los cortes de
  zona (`cortes`); no anulan nada. Si está vacío, se reparte la media manga en tres.
- `bloq[k]` = punto anulado, pintado sobre el plano. Es lo que dibuja los flotadores y
  la cadena, y lo único que resta capacidad. Anular un punto con cuerda la aparta a un
  hueco de su mismo claro, o a `extra` si no cabe.
- `extra[cat]` = cuerdas registradas sin sitio en el plano

`cap(b)` = `ancho × largo × 2 − puntos anulados`.

Las claves del formato anterior (`"claro-puntón"`, una cuerda por punto) se migran al
cargar con `migraBatea`: se leen como la cuerda de **proa**.

Helpers de geometría en `index.html`: `kCelda` / `leeK` (construir y leer claves),
`mediaManga` (puntones de cada costado), `ejeCol` (el puntón de la cadena, o `-1`),
`flotDe`, `esFlot`, `cortes`, `ladoCol` (`"babor"` / `"estribor"` / `"eje"`), `zonaCol`,
`colsDe`, `nombreBloque`, `dondeCelda`, `migraBatea`.

El puntón de la cadena no tiene zona: al seleccionar por zona forma un bloque de por sí,
para poder anularlo sin bajar a modo cuerda.

En el plano, la selección por zona se puede acotar a **las dos** cuerdas, solo **proa**
o solo **popa**.

El panel **Plano** (botón en la tarjeta de la batea) es donde se anulan los puntos y se
marcan los flotadores.

## Banco de pruebas

`banco.jsx` + `banco.shell.html` (en el scratchpad de la sesión) montan la rejilla real
fuera de la app, sin Firebase, y se publican como artifact. El JSX **se compila antes**
y React va embebido: los artefactos publicados no permiten `eval` ni cargaron los
scripts del CDN. `build.js` lo arma, `stress.js` recorre geometrías raras
(anchos impares incluidos) y `browser.js`, `anular.js`, `mitades.js` e `impar.js` lo
verifican en Chromium.

## Pendiente

- **Rarear** como operación de primera clase (repartir cuerdas amontonadas).
- `extra` ("cuerdas sin ubicar") pierde casi todo su sentido ahora que el plano tiene el
  doble de sitio: era un parche a un límite físico que en realidad no existe.
- Rendimiento: `Grid` no está memoizado y `loteInfo(b)` crea una función nueva en cada
  render; cada celda pintada reescribe el documento entero de Firestore.

## Convenciones

- Todo el código y la interfaz, en español, con el vocabulario de arriba.
- Un solo fichero, sin build: `index.html`. JSX transpilado por Babel en el navegador.
- Los datos viven en un único documento de Firestore por usuario, guardado con debounce.
