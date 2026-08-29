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
- **Zonas**: dentro de un medio claro, del alero hacia el eje, se distinguen tres
  tramos por referencias físicas, no por número: **ala**, **entre flotadores** y **medio**.
  No son cortes arbitrarios: **los marcan los propios flotadores**.

Así es como se nombra una cuerda hablando, y así debe leerse el plano:

> "cuerdas del 2º claro de babor" · "3er claro de estribor entre flotadores" ·
> "5º claro de babor del ala"

**Nadie dice "puntón 12".** El eje de puntones no se numera en pantalla: se rotula con
sus referencias (ala, entre flotadores, medio) y con los aleros como borde.

### Densidad: un punto de amarre NO es una cuerda

De un mismo punto de un puntón cuelgan **normalmente dos cuerdas**, a veces una, y a
veces muchas amontonadas cuando no hay sitio, para **rarearlas** (repartirlas) más
adelante. La capacidad física de la batea no es, por tanto, el número de celdas del
plano: el límite real es el normativo (500 cuerdas de venta + mexilla, 100 de colectora).

En los aleros normalmente no se amarran cuerdas, pero puede hacerse en ciertos momentos.

### Flotadores

Van **longitudinales**, bajo las vigas principales, y son **simétricos**: los mismos
puntones en los dos costados. Una batea lleva 4 (dos por costado) o 6 (tres).

**Encima de un flotador no se puede amarrar**, así que esos puntones no tienen puntos
de amarre — no es que estén ocupados, es que no existen. De ahí salen las tres zonas
de cada medio claro: **ala** del alero al primer flotador, **entre flotadores** entre
el primero y el último, y **medio** del último hasta el eje.

## Cómo se refleja en el modelo de datos

El objeto batea (`nuevaBatea`) usa claves `"fila-columna"`, que se leen así:

- **fila = claro**, `0` es el claro pegado a la cadena (el "1er claro" en pantalla)
- **columna = puntón**, de babor (izquierda) a estribor (derecha)
- `largo` = nº de claros = **vigas − 1** · `ancho` = nº de puntones
- `flot: [d, …]` = puntones por los que pasa un flotador, contados **desde el alero**
  (`0` = el pegado a él) y aplicados simétricamente a los dos costados. De aquí salen
  los cortes de zona (`cortes`). Si está vacío, se reparte la media manga en tres para
  tener algo con lo que hablar hasta que se marquen.
- `bloq[k]` = punto anulado a mano (no confundir con los flotadores, que se anulan solos)
- `extra[cat]` = cuerdas registradas sin sitio en el plano

`cap(b)` descuenta tanto los puntones de flotador como las celdas anuladas a mano.

Helpers de geometría en `index.html`: `mediaManga`, `flotDe`, `esFlot`, `cortes`,
`ladoCol`, `zonaCol`, `colsDe`, `nombreBloque`, `dondeCelda`.

## Banco de pruebas

`banco.jsx` + `banco.shell.html` (en el scratchpad de la sesión) montan la rejilla real
fuera de la app, sin Firebase, y se publican como artifact. El JSX **se compila antes**
y React va embebido: los artefactos publicados no permiten `eval` ni cargaron los
scripts del CDN. `build.js` lo arma y `browser.js` / `flotest.js` lo verifican en
Chromium.

## Pendiente (fase 2)

- **Densidad por celda**: hoy una celda es una cuerda (`celdas[k] = categoría`). Debe
  pasar a llevar cantidad, porque lo normal son dos cuerdas por punto.
- **Rarear** como operación de primera clase.
- Con densidad variable, `extra` ("cuerdas sin ubicar") pierde casi todo su sentido:
  era un parche a un límite físico que en realidad no existe.
- Rendimiento: `Grid` no está memoizado y `loteInfo(b)` crea una función nueva en cada
  render; cada celda pintada reescribe el documento entero de Firestore.

## Convenciones

- Todo el código y la interfaz, en español, con el vocabulario de arriba.
- Un solo fichero, sin build: `index.html`. JSX transpilado por Babel en el navegador.
- Los datos viven en un único documento de Firestore por usuario, guardado con debounce.
